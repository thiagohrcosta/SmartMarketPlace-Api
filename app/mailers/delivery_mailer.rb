class DeliveryMailer < ApplicationMailer
  default from: "no-reply@smartmarketplace.com"

  def status_updated
    @customer = params[:customer]
    @delivery = params[:delivery]

    mail(
      to: @customer.email,
      subject: "Your delivery status has been updated"
    )
  end
end
