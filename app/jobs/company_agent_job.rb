class CompanyAgentJob < ApplicationJob
  queue_as :default

  def perform
    Review.where("updated_at >= ?", 30.days.ago).find_each do |review|
      company = Company.find(review.company_id) if review.company_id
      # order = Order.find(review.order_id) if review.order_id
      # products = Order.product_orders.where(order_id: order.id).pluck(:product_id) if order

      next unless company

      result = moderate_review(review, company)
      puts result
      create_alert_if_needed(result, company)
    end
  end

  private

  def moderate_review(review, company)
    system_message = <<~SYSTEM
      You are an AI moderation assistant for an e-commerce platform.
      Evaluate the comment and return a JSON with:
        - kind: one of ["general_feedback", "scam", "fraud", "spam", "offensive", "delivery_issue", "other"]
        - risk_score: 0..100
        - flags: array of strings
        - company_id: the ID of the company being reviewed
        - message: use the flags to explain the decision based on flags and user feedback
    SYSTEM

    response = OpenAIClient.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: { review: review.comment, company_id: company.id }.to_json }
        ],
        temperature: 0
      }
    )

    content = response.dig("choices", 0, "message", "content")
    json = JSON.parse(content) rescue nil

    json ||= { "kind" => "general_feedback", "risk_score" => 0, "message" => "" }

    json["kind"] = Review.kinds[json["kind"]] || Review.kinds[:general_feedback]

    json
  end

  def create_alert_if_needed(result, company)
    return if result["kind"] == Review.kinds[:general_feedback]

    alert_type_int = case result["kind"]
                    when Review.kinds[:scam], Review.kinds[:fraud]
                      AlertMessage.alert_types[:critical]
                    when Review.kinds[:delivery_issue], Review.kinds[:offensive]
                      AlertMessage.alert_types[:warning]
                    else
                      AlertMessage.alert_types[:warning]
                    end

    AlertMessage.create!(
      message: result["message"],
      alert_type: alert_type_int,
      company_id: company.id,
    )

    if result["risk_score"] >= 80
      company.update(is_active: false)

      AlertMessage.create!(
        company_id: company.id,
        message: "Company blocked due to high risk review score.",
        alert_type: 0
      )

      Product.where(company_id: company.id).find_each do |product|
        product.update(status: 2)
      end
    end
  end
end
