class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.boolean :is_active, null: false, default: true
      t.integer :total
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
