require 'json'

# Understands solutions to a need for a rental car offer
class RentalOfferNeedPacket
  NEED = 'car_rental_offer'

  def initialize(user)
    @solutions = []
    @user = user
  end

  def initialize(user, location)
    @solutions = []
    @user = user
    @location = location
  end

  def to_json(*args)
    if @location 
      {
        'json_class' => self.class.name,
        'need' => NEED,
        'user' => @user,
        'location' => @location,
        'solutions' => @solutions
      }.to_json
    else
      {
        'json_class' => self.class.name,
        'need' => NEED,
        'user' => @user,
        'solutions' => @solutions
      }.to_json
    end
  end

  def propose_solution(solution)
    @solutions << solution
  end

end
