
Customer.destroy_all
Store.destroy_all
Order.destroy_all


######## CUSTOMERS ########
Customer.create(
  name: "Chris",
  email: "test",
  zip: 4,
  abv: 0.0,
)
Customer.create(
  name: "Carl",
  email: "cust2",
  zip: 2,
  abv: 0.0
)
Customer.create(
  name: "Jenny",
  email: "cust3",
  zip: 3,
  abv: 0.0
)
Customer.create(
  name: "Santa",
  email: "liqur_luvr@npole.com",
  zip: 2,
  abv: 0.0
)
Customer.create(
  name: "Santa",
  email: "liqur_luvr@npole.com",
  zip: 4,
  abv: 0.0
)
Customer.create(
  name: "Santa",
  email: "liqur_luvr@npole.com",
  zip: 1,
  abv: 0.0
)
######## STORES ########
Store.create(
  name: "Drunk Clam",
  rating: 5,
  zip: 4,
  specialty: "vodka"
)
Store.create(
  name: "Flatiron Keg",
  rating: 1,
  zip: 2,
  specialty: "rum"
)
Store.create(
  name: "BeerBox",
  rating: 5,
  zip: 2,
  specialty: "vodka"
)
Store.create(
  name: "The Bada Bing (The Sopranos)",
  rating: 4,
  zip: 1,
  specialty: "tequila"
)
Store.create(
  name: "MacLaren's Pub (How I Met Your Mother)",
  rating: 5,
  zip: 4,
  specialty: "tequila"
)
Store.create(
  name: "The Lusty Leopard (How I Met Your Mother)",
  rating: 10,
  zip: 3,
  specialty: "Vodka"
)
Store.create(
  name: "Dorsia (American Psycho)",
  rating: 3,
  zip: 1,
  specialty: "tequila"
)
Store.create(
  name: "Electric Psychedelic Pussycat Swingers Club (Austin Powers)",
  rating: 7,
  zip: 2,
  specialty: "rum"
)
Store.create(
  name: "The Delancy (168 Delancey St, New York, NY 10002)",
  rating: 9,
  zip: 4,
  specialty: "tequila"
)
Store.create(
  name: "The Hog's Head (Harry Potter)",
  rating: 5,
  zip: 1,
  specialty: "vodka"
)
Store.create(
  name: "Korova Milk Bar (A Clockwork Orange)",
  rating: 2,
  zip: 2,
  specialty: "vodka"
)
Store.create(
  name: "Paddy's Pub (Always Sunny in Philadelphia)",
  rating: 7,
  zip: 4,
  specialty: "rum"
)
Store.create(
  name: "The Nomad (1170 Broadway, New York, NY 10001)",
  rating: 8,
  zip: 3,
  specialty: "rum"
)
######## ORDERS ########
Order.create(
  customer_id: Customer.first.id,
  store_id: Store.first.id
)
Order.create(
  customer_id: Customer.second.id,
  store_id: Store.second.id
)
Order.create(
  customer_id: Customer.third.id,
  store_id: Store.third.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
Order.create(
  customer_id: Customer.take.id,
  store_id: Store.take.id
)
