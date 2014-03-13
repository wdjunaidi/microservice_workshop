require 'json'

# Understands solutions to a need for a rental car offer
class RentalOfferNeedPacket
  NEED = 'car_rental_offer'

  def initialize
    @need = NEED
    @solutions = {}
  end

  def to_json
    {
      'need' => @need,
      'solutions' => @solutions.to_json
    }.to_json
  end

  def propose_solution solution
    @solutions << solution
  end

end
