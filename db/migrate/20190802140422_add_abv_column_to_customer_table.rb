class AddAbvColumnToCustomerTable < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :abv, :float
  end
end
