class PhotoAgentJob < ApplicationJob
  queue_as :default

  def perform
    recent_products = Product.joins(:photos_attachments)
                             .where("products.updated_at >= ?", 1.hours.ago)
                             .where.not(status: :blocked)
                             .distinct

    recent_products.find_each { |product| validate_photos(product) }
  end

  private

  def validate_photos(product)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    product.photos.each do |photo|
      blob = photo.blob
      blob.analyze unless blob.analyzed?
      blob.reload

      image_url = blob.url
      puts "MODERATION FOR IMAGE URL: #{image_url}"

      moderation = moderate_image(client, product, image_url)
      puts moderation

      if moderation[:result] == "blocked"
        product.update(status: :blocked)

        AlertMessage.create!(
          product_id: product.id,
          message: "Image blocked: #{moderation[:reasons].join(', ')}. Suggestion: #{moderation[:suggestions]}",
          alert_type: 1,
          read: false
        )
      end
    end
  end

  def moderate_image(client, product, image_url)
    response = client.responses.create(
      parameters: {
        model: "gpt-4o",
        input: [
          {
            role: "system",
            content: <<~RULES
              You are a product image moderation system.

              You MUST return a valid JSON object:
              {
                "result": "allowed" | "blocked",
                "reasons": ["string", ...],
                "severity": "low" | "medium" | "high",
                "suggestions": "string"
              }

              RULES FOR IMAGES:
              - The image must relate to the product name and description.
              - Reject if the image depicts nudity, pornography, violence, drugs, cigarettes, or inappropriate content.
              - Reject if image quality is too low to identify the product.
              - Reject if text inside the image contradicts product name or description.
              - Reject if the image is irrelevant to the product.
              - If product is age_restricted:
                  - The image must correspond appropriately to an adult product.
              - Reject contradictory or incoherent content.

              IMPORTANT:
              - Always return well-formed JSON.
              - Add clear reasons.
              - Add suggestions for correction.
            RULES
          },
          {
            role: "user",
            content: [
              { type: "input_text", text: "Product name: #{product.name}" },
              { type: "input_text", text: "Product description: #{product.description}" },
              { type: "input_text", text: "Product age restricted: #{product.age_restricted}" },
              { type: "input_image", image_url: image_url }
            ]
          }
        ]
      }
    )

    json_text = response.dig("output", 0, "content", 0, "text")
    json_text = json_text.gsub(/```json|```/, "").strip

    JSON.parse(json_text).transform_keys(&:to_sym)
  rescue => e
    {
      result: "blocked",
      reasons: [ "Failed to parse moderation response: #{e.message}" ],
      severity: "high",
      suggestions: "Please upload a clear and valid product image."
    }
  end
end
