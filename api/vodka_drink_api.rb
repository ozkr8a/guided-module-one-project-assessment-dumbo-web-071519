require 'rest-client'
require 'json'

class GetVodkaDrinks

  URL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Vodka"

  def get_drinks
    vodka_response = RestClient.get(URL)
    vodka_response.body
  end

  def drink_list
    vodka_drinks = JSON.parse(self.get_drinks)
    vodka_drinks["drinks"].map do |drink|
      drink["strDrink"]
    end
  end

  def five_drinks
    drink_list.take(5)
  end

  def random_five_drinks
    five_drinks = []
    5.times {five_drinks << drink_list.sample}
    five_drinks
  end

end
