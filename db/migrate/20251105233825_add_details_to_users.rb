class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :full_name, :string
    add_column :users, :birthday, :date
    add_column :users, :role, :integer
    add_column :users, :address, :json
    add_column :users, :company_id, :integer
  end
end
