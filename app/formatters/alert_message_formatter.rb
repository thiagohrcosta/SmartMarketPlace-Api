class AlertMessageFormatter
  include Rails.application.routes.url_helpers

  def initialize(alert_message)
    @alert_message = alert_message
  end

  def call
    if @alert_message.is_a?(Enumerable)
      @alert_message.map { |msg| self.class.new(msg).call }
    else
      format_single(@alert_message)
    end
  end

  private

  def format_single(alert_message)
    {
      id: alert_message.id,
      company_id: alert_message.company_id,
      message: alert_message.message,
      read: alert_message.read,
      alert_type: alert_message.alert_type,
      product_id: alert_message.product_id,
      created_at: alert_message.created_at,
      updated_at: alert_message.updated_at
    }
  end
end
