# Understands a specific solution to a rental car offer need
class RentalOfferSolution

  def initialize(traits)
    @traits = traits
  end

  def to_json
    @traits.to_json
  end

end
