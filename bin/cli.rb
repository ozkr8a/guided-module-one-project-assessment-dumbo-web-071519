require_relative '../config/environment'

class Interface
  attr_accessor :prompt, :customer

  def initialize()
    @prompt = TTY::Prompt.new
    @customer = {}
  end

  def login
    # pid = fork{ exec "afplay", "pp_theme.mp3" }
    @prompt.select("LOGIN OR CREATE A NEW ACCOUNT") do |menu|
      menu.choice "LOGIN", -> {old_customer()}
      menu.choice "CREATE ACCOUNT", -> {new_customer()}
      menu.choice "EXIT", -> {exit_program()}
    end
  end

  def new_customer
    @prompt.say("LET'S GET SOME INFORMATION...")
    @customer = @prompt.collect do
      key(:name).ask('NAME?')
      key(:email).ask('EMAIL?')
      key(:zip).ask('ZIP CODE?', convert: :int)
    end

    Customer.create(@customer)
    main_menu()
  end

  def old_customer
    customer_email = @prompt.ask("What is your email?")
    if Customer.find_by(email: customer_email) == nil
      @prompt.say("WE COULDN'T FIND YOU IN THE SYSTEM! LET'S CREATE A NEW ACCOUNT...")
      new_customer()
    else
      @customer = Customer.find_by(email: customer_email)
      @prompt.say("WELCOME BACK #{@customer[:name]}".upcase)
      #other better ways to do this... #
      sleep(2)
      main_menu()
    end
  end

  def main_menu
    system "clear"
    #user.reload
    @prompt.select("WHAT WOULD YOU LIKE TO SEARCH BY?") do |menu|
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

    prompt.select("HERE ARE YOUR NEARBY STORES", [nearby_store_names])
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
      menu.choice "BACK", -> {main_menu()}
    end
  end

  def check_out(store)
    binding.pry
    prompt.ask("PLEASE CONFIRM YOUR ORDER OF #{store.specialty}".upcase)
    Store.find_by(name: store)
  end

  def exit_program
    #fork{ exec "killall", "afplay" }
    @prompt.say("Goodbye!")
    exit!
  end

end
