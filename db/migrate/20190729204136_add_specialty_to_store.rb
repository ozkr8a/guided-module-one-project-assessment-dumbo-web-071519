class AddSpecialtyToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :specialty, :string
  end
end
