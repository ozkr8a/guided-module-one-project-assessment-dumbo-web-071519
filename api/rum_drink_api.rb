require 'rest-client'
require 'json'

class GetRumDrinks

  URL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Rum"

  def get_drinks
    rum_response = RestClient.get(URL)
    rum_response.body
  end

  def drink_list
    rum_drinks = JSON.parse(self.get_drinks)
    rum_drinks["drinks"].map do |drink|
      drink["strDrink"]
    end
  end

  def five_drinks
    drink_list.take(5)
  end

  def random_five_drinks
    answer = []
    5.times {answer << drink_list.sample}
    answer
  end

end
