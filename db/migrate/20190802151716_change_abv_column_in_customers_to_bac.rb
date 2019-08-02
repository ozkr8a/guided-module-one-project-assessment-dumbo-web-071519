class ChangeAbvColumnInCustomersToBac < ActiveRecord::Migration[5.2]
  def change
    rename_column :customers, :abv, :bac
  end
end
