class AddVerifiedAndReputationToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :verified, :boolean, default: false
    add_column :companies, :reputation, :integer, default: 0
    add_column :companies, :is_active, :boolean, default: true
  end
end
