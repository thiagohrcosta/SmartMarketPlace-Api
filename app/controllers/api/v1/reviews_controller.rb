module Api
  module V1
    class ReviewsController < Api::V1::BaseController
      def create
        review = Review.new(review_params)
        review.user = current_user

        # return render json: { errors: "You can't review an order twice." }, status: :unprocessable_entity if Review.exists?(order_id: review.order_id, user_id: current_user.id)

        moderation_result = ReviewAgentService.new(review.comment, current_user).call

        if moderation_result["approved"] == true
          review.kind = moderation_result["kind"]

          if review.save
            company_rating = Review.where(company_id: review.company_id).average(:rating).to_f
            @company = Company.find(review.company_id)
            @company.update(reputation: company_rating)
            render json: { review: review }, status: :created
          end
        else
          render json: { errors: moderation_result["message"] }, status: :unprocessable_entity
        end
      end

      private

      def review_params
        params.require(:review).permit(:comment, :rating, :order_id, :company_id)
      end
    end
  end
end
