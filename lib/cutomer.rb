class Customer < ActiveRecord::Base

    has_many :orders
    has_many :stores, through: :orders

end
