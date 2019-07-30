
# TO DO:
# 1) change 'search_menu' function to 'search_menu'
# 2) make new 'main menu' have options to
# ==> a) update account -> (*new function)
# ===> b) see order history -> (*new function)
# ====> c) start new order -> search_menu()

require_relative '../config/environment'

class Interface
  attr_accessor :prompt, :customer

  def initialize()
    @prompt = TTY::Prompt.new(active_color: :bright_blue)
    @customer = {}
  end

  def login
    # pid = fork{ exec "afplay", "pp_theme.mp3" }
    system "clear"
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
      search_menu()
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
      sleep(1.5)
      prompt.say("TAKING YOU BACK TO THE LOGIN SCREEN...")
      sleep(1.5)
      login()
    else
      prompt.say("TAKING YOU BACK TO MAIN MENU...")
      sleep(1.5)
      search_menu()
    end

  end

  def exit_program
    #fork{ exec "killall", "afplay" }
    prompt.say("GOODBYE!".red.bold)
    exit!
  end

end
