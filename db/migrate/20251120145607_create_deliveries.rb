class CreateDeliveries < ActiveRecord::Migration[7.2]
  def change
    create_table :deliveries do |t|
      t.references :courier, null: true, foreign_key: { to_table: :users }
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :order, null: false, foreign_key: true

      t.string :status, null: false, default: "pending_pickup"
      t.string :received_by
      t.text :delivery_address

      t.datetime :picked_up_at
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
