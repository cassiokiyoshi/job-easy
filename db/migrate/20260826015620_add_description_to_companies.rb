class AddDescriptionToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :description, :text
  end
end
