class CreateProductOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :product_orders do |t|
      t.timestamps
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :amount, null: false, default: 1
    end
  end
end
