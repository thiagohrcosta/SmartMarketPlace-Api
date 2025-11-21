class AddCompanyToAlertMessages < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:alert_messages, :company_id)
      add_reference :alert_messages, :company, null: true, foreign_key: true
    end
  end
end
