class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.timestamps
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :payment_method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.jsonb :payload
    end
  end
end
