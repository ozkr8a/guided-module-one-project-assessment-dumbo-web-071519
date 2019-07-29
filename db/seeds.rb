

c1 = Customer.create(name: "Ana", email: "cust1@cust.com", zip: 11)
c2 = Customer.create(name: "Carl", email: "cust2@cust.com", zip: 32)
c3 = Customer.create(name: "Jenny", email: "cust3@cust.com", zip: 18)
c4 = Customer.create(name: "Santa", email: "liqur_luvr@npole.com", zip: 83)


s1 = Store.create(name: "Drunk Clam", rating: 5, zip: 24)
s2 = Store.create(name: "Roscoe's", rating: 4, zip: 40)
s3 = Store.create(name: "Flatiron Keg", rating: 1, zip: 90)
s4 = Store.create(name: "BeerBox", rating: 5, zip: 89)

o1 = Order.create(customer_id: Customer.first.id, store_id: Store.first.id)
o2 = Order.create(customer_id: Customer.second.id, store_id: Store.second.id)
o3 = Order.create(customer_id: Customer.third.id, store_id: Store.third.id)
o4 = Order.create(customer_id: Customer.fourth.id, store_id: Store.fourth.id)






