class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.timestamps
      t.text :comment, null: false
      t.integer :rating, null: false
      t.integer :kind, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
    end
  end
end
