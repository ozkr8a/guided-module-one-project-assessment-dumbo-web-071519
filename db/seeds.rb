
Customer.destroy_all
Store.destroy_all
Order.destroy_all


######## CUSTOMERS ########
c1 = Customer.create(
  name: "Chris",
  email: "test",
  zip: 4
)
c2 = Customer.create(
  name: "Carl",
  email: "cust2@cust.com",
  zip: 2
)
c3 = Customer.create(
  name: "Jenny",
  email: "cust3@cust.com",
  zip: 3
)
c4 = Customer.create(
  name: "Santa",
  email: "liqur_luvr@npole.com",
  zip: 1
)

######## STORES ########
s1 = Store.create(
  name: "Drunk Clam",
  rating: 5,
  zip: 4,
  specialty: "vodka"
)
s2 = Store.create(name: "Roscoe's",rating: 4,
  zip: 3,
  specialty: "rum"
)
s3 = Store.create(name: "Flatiron Keg",
  rating: 1,
  zip: 2,
  specialty: "rum"
)
s4 = Store.create(name: "BeerBox",
  rating: 5,
  zip: 2,
  specialty: "vodka"
)
s5 = Store.create(name: "BeerBox2",
  rating: 4,
  zip: 1,
  specialty: "tequila"
)
s6 = Store.create(name: "BeerBox3",
  rating: 5,
  zip: 4,
  specialty: "tequila"
)

######## ORDERS ########
o1 = Order.create(
  customer_id: Customer.first.id,
  store_id: Store.first.id
)
o2 = Order.create(
  customer_id: Customer.second.id,
  store_id: Store.second.id
)
o3 = Order.create(
  customer_id: Customer.third.id,
  store_id: Store.third.id
)
o4 = Order.create(
  customer_id: Customer.fourth.id,
  store_id: Store.fourth.id
)
