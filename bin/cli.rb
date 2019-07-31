#### TO DO ####
# => add rating_search()
# => finish order_history()
# => add a back button to zip code search


require_relative '../config/environment'

class Interface
  attr_accessor :prompt, :customer
  attr_reader :vodka_drinks, :rum_drinks, :tequila_drink

  def initialize()
    @prompt = TTY::Prompt.new(active_color: :bright_blue)
    @customer = {}
    @vodka_drinks = GetVodkaDrinks.new
    @rum_drinks = GetRumDrinks.new
    @tequila_drinks = GetTequilaDrinks.new
  end

  def run_catpix
    Catpix::print_image "pictures/beer6.png",
      :limit_x => 0.4,
      :limit_y => 0.8,
      :center_x => true,
      :center_y => true,
      :bg => "black",
      :bg_fill => true,
      :resolution => "high"
  end

  def login
    # pid = fork{ exec "afplay", "pp_theme.mp3" }
    # system "clear"
    run_catpix()
    prompt.select("LOGIN OR CREATE A NEW ACCOUNT".light_green.bold) do |menu|
      menu.choice "LOGIN", -> {old_customer()}
      menu.choice "CREATE ACCOUNT", -> {new_customer()}
      menu.choice "EXIT", -> {exit_program()}
    end
  end

  def new_customer
    prompt.say("LET'S GET SOME INFORMATION...")
    customer_hash = prompt.collect do
      key(:name).ask('NAME?')
      key(:email).ask('EMAIL?')
      key(:zip).ask('ZIP CODE?', convert: :int)
    end

    @customer = Customer.create(customer_hash)

    search_menu()
  end

  def old_customer
    customer_email = prompt.ask("What is your email?")
    if Customer.find_by(email: customer_email) == nil
      prompt.say("WE COULDN'T FIND YOU IN THE SYSTEM! LET'S CREATE A NEW ACCOUNT...")
      sleep(1.5)
      new_customer()
    else
      @customer = Customer.find_by(email: customer_email)
      prompt.say("WELCOME BACK #{@customer[:name]}! 🍻".upcase.yellow.italic)
      #other better ways to do this...? #
      sleep(1.5)
      main_menu()
    end
  end

  def main_menu
    prompt.select("MAIN MENU") do |menu|
      menu.choice "UPDATE ACCOUNT", -> {update_account()}
      menu.choice "SEE ORDER HISTORY", -> {order_history()}
      menu.choice "PLACE NEW ORDER", -> {search_menu()}
      menu.choice "DELETE ACCOUNT", -> {delete_account()}
    end
  end

  def update_account
    prompt.select("WHAT ACCOUNT INFO WOULD YOU LIKE TO UPDATE?") do |menu|
      menu.choice "NAME", -> {update_handler("name")}
      menu.choice "EMAIL", -> {update_handler("email")}
      menu.choice "ZIP CODE", -> {update_handler("zip")}
    end
  end

  def update_handler(column)
    new_value = prompt.ask("WHAT WOULD YOU LIKE YOUR NEW #{column} TO BE?".upcase)
    Customer.find(@customer.id).update("#{column}": new_value)
    prompt.say("YOU'VE SUCCESFULLY CHANGED YOUR #{column} to #{new_value}")
    sleep(1.5)
    prompt.say("TAKING YOU BACK TO MAIN MENU...")
    main_menu()
  end

  def order_history

    list_of_orders = Order.where(customer_id: self.customer.id).pluck(:id).map do |order_id|
      Order.find(order_id)
    end

    list_of_stores = list_of_orders.map do |order|
      Store.find(order.store_id)
    end
    list_of_order_prices = Order.where(customer_id: self.customer.id).pluck(:price)
    list_of_order_products = Order.where(customer_id: self.customer.id).pluck(:product)
    list_of_store_names = list_of_stores.map do |store|
      store.name
    end

    old_order_strings_array = []

    i=0
    while (i < list_of_stores.count)
      old_order_strings_array << "Your order from #{list_of_store_names[i]} of #{list_of_order_products[i]} for $#{list_of_order_prices[i]}."
      i+=1
    end

    # Turn array into 'option_hash' => (k=string, v=function)
    # Pass option_hash as arg to tty-prompt
    old_order_strings_hash = {}
    binding.pry

    old_order_strings_array.map do |order_string|
      binding.pry
      old_order_strings_hash[order_string] = x[]
    end
    binding.pry
    old_order_strings_hash["BACK"] = 0

    reorder_order = prompt.select("HERE ARE YOUR OLD ORDERS. CHOOSE ONE TO RE-ORDER IT!", old_order_strings_hash)

    store_name = ""
    binding.pry
    reorder_order_array = reorder_order.split
    if reorder_order_array.count == 9
      store_name = "#{reorder_order_array[3]} #{reorder_order_array[4]}"
    else # reorder_order_array.count == 8
      store_name = reorder_order_array[3]
    end
    checkout_store = Store.find_by(name: store_name)
    # "order history"
  end

  def reorder_handler
    case order
    when 0
      search_menu()
    when 1
      check_out(checkout_store)
    end
  end

  def search_menu
    system "clear"
    #user.reload
    prompt.select("WHAT WOULD YOU LIKE TO SEARCH BY?") do |menu|
      menu.choice "SEARCH BY ZIP CURRENT CODE", -> {zip_search()}
      menu.choice "SEARCH BY LIQUOR", -> {liquor_search()}
      menu.choice "LOGIN AS A DIFFERENT CUSTOMER", -> {login()}
    end
  end

  def delete_account
    confirm_destroy = prompt.yes?("ARE YOU SURE?".red.bold)
    if confirm_destroy
      Customer.find_by(name: @customer.name).destroy
      sleep(0.5)
      prompt.say("HASTA LA VISTA BABY...'ALL BEE BACK'...☠️".red.italic)
      sleep(1.5)
      prompt.say("TAKING YOU BACK TO LOGIN...")
      sleep(1)
      login()
    else
      prompt.say("TAKING YOU BACK TO MAIN MENU".green.italic)
      main_menu()
    end
  end

  def zip_search
    customer_zip = customer[:zip]
    nearby_stores = Store.where(zip: customer_zip)
    nearby_store_names =  nearby_stores.map do |nearby_stores|
      nearby_stores.name
    end

    store = prompt.select("YOUR ZIP CODE IS #{customer.zip}. HERE ARE YOUR NEARBY STORES", [nearby_store_names])
    store_specialty = Store.find_by(name: store).specialty

    confirm_store = prompt.yes?("#{store}'S SPECIALTY IS #{store_specialty}. WOULD YOU LIKE TO CHECK OUT?".upcase.yellow.bold)

    if confirm_store
      check_out(store)
    else
      prompt.say("TAKING YOU BACK TO MAIN MENU...")
      sleep(1.5)
      search_menu()
    end
  end

  def find_by_speciality(liquor)
    store_names_by_specialty = Store.where(specialty: liquor).map do |store|
      store.name
    end

    stores_by_specialty = Store.where(specialty: liquor)

    store = prompt.select("HERE ARE STORES THAT SPECIALIZE IN #{liquor}:".upcase, [store_names_by_specialty])
    check_out(store)
  end

  def liquor_search
    @prompt.select("WHAT WOULD YOU LIKE TO DRINK?") do |menu|
      menu.choice "VODKA", -> {find_by_speciality("vodka")}
      menu.choice "RUM", -> {find_by_speciality("rum")}
      menu.choice "TEQUILA", -> {find_by_speciality("tequila")}
      menu.choice "BACK", -> {search_menu()}
    end
  end

  def check_out(store)
    current_store = Store.find_by(name: store)
    price = rand(9.99..21.01).round(2)
    confirm = prompt.yes?("PLEASE CONFIRM YOUR ORDER OF #{current_store.specialty} for $#{price} from #{current_store.name}!".upcase.green.bold)

    if confirm
      new_order = Order.create(customer_id: self.customer.id, store_id: current_store.id, price: price, product: current_store.specialty)
      prompt.say("THANK YOU FOR PLACING AN ORDER OF #{current_store.specialty} for $#{price} with #{current_store.name}! PLEASE ORDER AGAIN SOON!!!".upcase.light_green.bold)

      # prompt.select("WOULD YOU LIKE TO RATE THE LIQUOR STORE?") do |menu|
      #   menu.choice "SURE", -> {rate_store(current_store)}
      #   menu.choice "NO THANKS", -> {}

      sleep(1.5)
      prompt.say("SHOWING YOU A LIST OF 5 RANDOM #{current_store.specialty} DRINKS YOU CAN MAKE!".upcase)

      if current_store.specialty == "vodka"
        self.get_vodka_drinks.each do |drink|
          prompt.say("#{drink}")
        end
      elsif current_store.specialty == "rum"
        self.get_rum_drinks.each do |drink|
          prompt.say("#{drink}")
        end
      elsif current_store.specialty == "tequila"
        self.get_tequila_drinks.each do |drink|
          prompt.say("#{drink}")
        end
      end

      prompt.keypress("PRESS ANY KEY TO CONTINUE...")
      rate_store(current_store)
    else
      to_search_menu()
    end
  end

  def to_search_menu
    prompt.say("TAKING YOU BACK TO MAIN MENU...")

    sleep(1.5)
    search_menu()
  end

  def rate_store(store)
    rating = prompt.slider('PLEASE GIVE THE STORE A RATING', max: 10, step: 1, default: 5)
    store.update(rating: rating)
    prompt.say("THANK YOU FOR RATING #{store.name}")

    sleep(1.5)
    to_search_menu()
  end

  def get_vodka_drinks
    @vodka_drinks.random_five_drinks()
  end

  def get_rum_drinks
    @rum_drinks.random_five_drinks()
  end

  def get_tequila_drinks
    @tequila_drinks.random_five_drinks()
  end

  # def get_drinks(alcohol)
  #   method_name = "@#{alcohol}_drinks"
  #   "#{method_name}".random_five_drinks()
  # end

  def exit_program
    #fork{ exec "killall", "afplay" }
    prompt.say("GOODBYE!".red.bold)
    exit!
  end

end
