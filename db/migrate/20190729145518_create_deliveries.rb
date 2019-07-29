class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.integer :store_id
      t.float :price
      t.string :products
    end
  end
end
