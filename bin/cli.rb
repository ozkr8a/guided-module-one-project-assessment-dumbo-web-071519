#### TO DO ####
# => add rating_search()
# => finish order_history() ???
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
      :limit_y => 1.2,
      :center_x => true,
      :center_y => true,
      :bg => "black",
      :bg_fill => true,
      :resolution => "high"
  end


  def self.get_orders(customer)
    customer.orders
  end


  def login
    # pid = fork{ exec "afplay", "pp_theme.mp3" }
    # system "clear"
    run_catpix()
    prompt.select("==> LOGIN OR CREATE A NEW ACCOUNT".light_green.bold) do |menu|
      menu.choice "LOGIN", -> {old_customer()}
      menu.choice "CREATE ACCOUNT", -> {new_customer()}
      menu.choice "EXIT", -> {exit_program()}
    end
  end


  def new_customer
    prompt.say("==> LET'S GET SOME INFORMATION...".light_green.bold)
    customer_hash = prompt.collect do
      key(:name).ask('NAME?')
      key(:email).ask('EMAIL?')
      key(:zip).ask('ZIP CODE?', convert: :int)
    end

    @customer = Customer.create(customer_hash)

    search_menu()
  end


  def old_customer
    customer_email = prompt.ask("WHAT'S YOUR EMAIL?")
    if Customer.find_by(email: customer_email) == nil
      prompt.say("==> WE COULDN'T FIND YOU IN THE SYSTEM! LET'S CREATE A NEW ACCOUNT...".light_yellow.bold)
      sleep(1.5)
      new_customer()
    else
      @customer = Customer.find_by(email: customer_email)
      prompt.say("==> WELCOME BACK #{@customer[:name]}! 🍻".upcase.light_yellow.italic)
      #other better ways to do this...? #
      sleep(1.5)
      main_menu()
    end
  end


  def main_menu
    prompt.select("==> MAIN MENU".light_green.bold) do |menu|
      menu.choice "UPDATE ACCOUNT", -> {update_account()}
      menu.choice "SEE ORDER HISTORY", -> {order_history()}
      menu.choice "PLACE NEW ORDER", -> {search_menu()}
      menu.choice "DELETE ACCOUNT", -> {delete_account()}
      menu.choice "LOGOUT", -> {login()}
    end
  end


  def update_account
    prompt.select("==> WHAT ACCOUNT INFO WOULD YOU LIKE TO UPDATE?".light_green.bold) do |menu|
      menu.choice "NAME", -> {update_handler("name")}
      menu.choice "EMAIL", -> {update_handler("email")}
      menu.choice "ZIP CODE", -> {update_handler("zip")}
      menu.choice "BACK", -> {main_menu()}
    end
  end


  def update_handler(column)
    new_value = prompt.ask("==> WHAT WOULD YOU LIKE YOUR NEW #{column} TO BE?".upcase.light_green.bold )
    Customer.find(@customer.id).update("#{column}": new_value)
    prompt.say("==> YOU'VE SUCCESFULLY CHANGED YOUR #{column} to #{new_value}".light_green.bold)
    sleep(1.5)
    prompt.say("==> TAKING YOU BACK TO MAIN MENU...".light_green.bold)
    main_menu()
  end


  def order_history
    list_of_orders = @customer.orders
    list_of_order_prices = Order.where(customer_id: self.customer.id).pluck(:price)
    list_of_order_products = Order.where(customer_id: self.customer.id).pluck(:product)
    list_of_order_ids = Order.where(customer_id: self.customer.id).pluck(:id)

    list_of_stores = @customer.stores
    list_of_store_names = list_of_stores.map { |store| store.name }

    old_order_strings_array = []

    i=0
    while (i < list_of_stores.count)
      old_order_strings_array << "==> Your order from #{list_of_store_names[i]} of #{list_of_order_products[i]} for $#{list_of_order_prices[i]}.".upcase
      i+=1
    end

    processed_old_order_strings_array = old_order_strings_array.map do |string|
      string.slice(4..-1)
    end

    processed_old_order_strings_array << "BACK"

    # =====> ORDER ARRAY TO HASH (K=array entry, V=store_instance) <=====
    # ===================================================================
    old_order_hash = {}
    j=0
    processed_old_order_strings_array.each do |string|
      old_order_hash[string] = list_of_orders[j]
      j+=1
    end
    # ===========================>  END  <===============================

    reorder_order_selection = prompt.select("==> HERE ARE YOUR OLD ORDERS. CHOOSE ONE TO RE-ORDER IT!".light_green.bold, old_order_hash.keys)

    re_order_handler(old_order_hash, reorder_order_selection)

  end

  def re_order_handler(order_hash, selection)
    if selection == "BACK"
      to_search_menu()
    else
      re_order(order_hash, selection)
    end
  end

  def re_order(order_hash, selection)
    confirm_selection = prompt.yes?("ARE YOU SURE YOU WANT TO RE-ORDER #{selection}".upcase.light_yellow.bold)
    if confirm_selection
      binding.pry
      Order.create(customer_id: order_hash[selection].customer_id, store_id: order_hash[selection].store_id, price: order_hash[selection].price, product: order_hash[selection].product)
      prompt.say("YOUR ORDER HAS BEEN PLACED! PLEASE DRINK RESPONSIBLY!".light_green.bold)
      sleep(1.5)
      to_search_menu()
    else
      to_search_menu()
    end
  end

  def search_menu
    system "clear"
    #user.reload
    prompt.select("==> WHAT WOULD YOU LIKE TO SEARCH BY?".light_green.bold) do |menu|
      menu.choice "SEARCH BY ZIP CURRENT CODE", -> {zip_search()}
      menu.choice "SEARCH BY LIQUOR", -> {liquor_search()}
      menu.choice "BACK", -> {main_menu()}
    end
  end

  def delete_account
    confirm_destroy = prompt.yes?("==> ARE YOU SURE?".red.bold)
    if confirm_destroy
      Customer.find_by(name: @customer.name).destroy
      sleep(0.5)
      prompt.say("==> HASTA LA VISTA BABY ☠️".light_red.italic)
      sleep(1.5)
      prompt.say("==> TAKING YOU BACK TO LOGIN...")
      sleep(1)
      login()
    else
      prompt.say("==> TAKING YOU BACK TO MAIN MENU".green.italic)
      main_menu()
    end
  end

  def zip_search
    customer_zip = customer[:zip]
    nearby_stores = Store.where(zip: customer_zip)
    nearby_store_names =  nearby_stores.map do |nearby_stores|
      nearby_stores.name
    end

    store = prompt.select("==> YOUR ZIP CODE IS #{customer.zip}. HERE ARE YOUR NEARBY STORES".light_green.bold, [nearby_store_names])
    store_specialty = Store.find_by(name: store).specialty

    confirm_store = prompt.yes?("==> #{store}'S SPECIALTY IS #{store_specialty}. WOULD YOU LIKE TO CHECK OUT?".upcase.yellow.bold)

    if confirm_store
      check_out(store)
    else
      prompt.say("==> TAKING YOU BACK TO MAIN MENU...".light_green.bold)
      sleep(1.5)
      search_menu()
    end
  end

  def find_by_speciality(liquor)
    store_names_by_specialty = Store.where(specialty: liquor).map do |store|
      store.name
    end

    stores_by_specialty = Store.where(specialty: liquor)

    store = prompt.select("==> HERE ARE STORES THAT SPECIALIZE IN #{liquor}:".upcase.light_green.bold, [store_names_by_specialty])
    check_out(store)
  end

  def liquor_search
    @prompt.select("==> WHAT WOULD YOU LIKE TO DRINK?".light_green.bold) do |menu|
      menu.choice "VODKA", -> {find_by_speciality("vodka")}
      menu.choice "RUM", -> {find_by_speciality("rum")}
      menu.choice "TEQUILA", -> {find_by_speciality("tequila")}
      menu.choice "BACK", -> {search_menu()}
    end
  end

  def check_out(store)
    current_store = Store.find_by(name: store)
    price = rand(14.99..25.01).round(2)
    confirm = prompt.yes?("==> PLEASE CONFIRM YOUR ORDER OF #{current_store.specialty} for $#{price} from #{current_store.name}!".upcase.light_yellow)

    if confirm
      new_order = Order.create(customer_id: self.customer.id, store_id: current_store.id, price: price, product: current_store.specialty)
      prompt.say("==> THANK YOU FOR PLACING AN ORDER OF #{current_store.specialty} for $#{price} with #{current_store.name}. PLEASE ORDER AGAIN SOON!".upcase.light_green)

      sleep(1.5)
      prompt.say("    ==> HERE ARE 5 DRINK IDEAS YOU CAN MAKE WITH #{current_store.specialty}!".upcase.light_green)

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

      prompt.keypress("==> PRESS ANY KEY TO CONTINUE...".light_green.bold)
      rate_store(current_store)
    else
      to_search_menu()
    end
  end

  def to_search_menu
    prompt.say("==> TAKING YOU BACK TO MAIN MENU...".light_green.bold)
    sleep(1)
    prompt.say("==> ...".light_green.bold)
    sleep(1)
    prompt.say("==> ...".light_green.bold)
    sleep(1)
    search_menu()
  end

  def rate_store(store)
    rating = prompt.slider("==> PLEASE GIVE THE STORE A RATING".light_green.bold, max: 10, step: 1, default: 5)
    store.update(rating: rating)
    prompt.say("==> THANK YOU FOR RATING #{store.name}".upcase.light_green.bold)

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
    prompt.say("==> GOODBYE!".red.italic)
    exit!
  end

end
