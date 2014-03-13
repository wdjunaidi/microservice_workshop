require 'json'

# Understands solutions to a need for a rental car offer
class RentalOfferNeedPacket
  NEED = 'car_rental_offer'

  attr_reader :need, :solutions

  def initialize(need_instance_id = 'default', solutions = [])
    @need, @need_instance_id = NEED, need_instance_id
    @solutions = solutions
  end

  def to_json(*args)
    {
      json_class: self.class.name,
      need: @need,
      need_instance_id: @need_instance_id,
      solutions: @solutions
    }.to_json
  end

  def self.json_create(json_hash)
    new(json_hash['need_instance_id'], json_hash['solutions'])
  end

  def propose_solution solution
    @solutions << solution
  end

  def unsatisfied?
    @solutions.empty?
  end

end
