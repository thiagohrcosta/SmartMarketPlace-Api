require "fuzzy_match"

class ReviewAgentService
  def initialize(product, user)
    @product = product
    @user = user
  end

  def call
    system_message = <<~SYSTEM
      You are a balanced and smart content moderation agent for product reviews.
      You must use sentiment analysis, semantic interpretation, and common sense.

      IMPORTANT RULE (highest priority):
      - If the review reports a REAL PROBLEM such as:
          scam, fraud, stolen money, suspicious seller behavior, spam, delivery problems,
        the review MUST ALWAYS be approved (approved = true) because it needs to be forwarded
        to the moderation and investigation team.
      - Under no circumstance should a complaint or problem report be rejected.

      Reject ONLY if the comment contains:
        - profanity or insults directed at people
        - hate speech
        - explicit sexual content
        - explicit violence
        - illegal drug promotion
        - meaningless/broken text that cannot be understood
        - commercial spam that is not related to a problem (e.g. advertising unrelated sites)

      Positive, neutral, short or simple reviews MUST be approved.

      When kind is: scam, fraud, spam, delivery_issue
        → ALWAYS generate a clear admin-friendly message summarizing the issue.

      Output format (always JSON follow this EXACT format):
        {
          "approved": true or false,
          "message": "",
          "kind": "scam|fraud|spam|offensive|delivery_issue|general_feedback|other"
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