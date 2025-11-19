class CreateAlertMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :alert_messages do |t|
      t.timestamps
      t.string :message, null: false
      t.boolean :read, default: false, null: false
      t.integer :alert_type, null: false
      t.references :product, null: false, foreign_key: true
    end
  end
end
