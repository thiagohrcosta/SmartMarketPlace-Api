class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :discount_percentage
      t.boolean :age_restricted
      t.integer :status
      t.integer :stock
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
