class ChangeOrdersTableProductsColumnToProduct < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :products, :product
  end
end
