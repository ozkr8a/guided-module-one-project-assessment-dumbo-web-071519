require 'rest-client'
require 'json'

class GetTequilaDrinks

  URL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Tequila"

  def get_drinks
    tequila_response = RestClient.get(URL)
    tequila_response.body
  end

  def drink_list
    tequila_drinks = JSON.parse(self.get_drinks)
    tequila_drinks["drinks"].map do |drink|
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
