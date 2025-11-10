require "fuzzy_match"

class ProductAgentService
  def initialize(product, user)
    @product = product
    @user = user
  end

  def call
    system_message = <<~SYSTEM
      You are a strict content moderation agent for product listings in a marketplace.
      Your goal is to prevent inappropriate, unsafe, or misleading products from being approved.

      You must always respond in English.

      - RULES:
        1. If the product name or description includes any terms like “adult”, "only adults", “18+”, “restricted”, “explicit”, “beer”, “wine”, “vodka”, “cigarette”, or any other +18 related content, you must set "age_restricted" to true or reject if it’s false.
        2. If the product name or description includes profanity, sexual, violent, or drug-related words, you must reject the product.
        3. If the product name or description appears nonsensical or unrelated to real products, reject it and ask for clarification.
        4. The Product kind should be compared to description, if you think that the name and description should point something to age_restricted = true, just send the message.
        5. You must return a JSON in the format:

      Example of what kind of Data you should receive to review
        {
          "product": {
            "company_id": Int,
            "name": String,
            "description": Text,
            "price": Int,
            "age_restricted": boolean,
            "status": Int,
            "stock": Int
          }
        }

      Based on that kind of data you should answer  following the E.G below always in JSON
        {
          "approved": true or false,
          message: "" <---- if approved was false you should point the reasons that this product can't be created
        }
    SYSTEM

    response = OpenAIClient.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: "#{@product}: #{@user}" }
        ],
        temperature: 0
      }
    )

    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content)
  rescue JSON::ParserError
    { "approved" => false, "message" => "Invalid response from AI" }
  end
end