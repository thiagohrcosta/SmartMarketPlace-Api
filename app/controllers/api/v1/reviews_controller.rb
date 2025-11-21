module Api
  module V1
    class ReviewsController < Api::V1::BaseController
      def create
        review = Review.new(review_params)
        review.user = current_user

        # here need to call the review agent service rb
        moderation_result = ReviewAgentService.new(review.comment, current_user).call

        puts moderation_result

        # if review.save
        #   render json: { review: review }, status: :created
        # else
        #   render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        # end
      end

      private

      def review_params
        params.require(:review).permit(:comment, :rating, :order_id)
      end
    end
  end
end
