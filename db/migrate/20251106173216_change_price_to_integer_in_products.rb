class ChangePriceToIntegerInProducts < ActiveRecord::Migration[7.2]
  def up
    Product.find_each do |product|
      product.update_column(:price, product.price.to_i)
    end

    change_column :products, :price, :integer
  end

  def down
    change_column :products, :price, :decimal, precision: 10, scale: 2
  end
end
