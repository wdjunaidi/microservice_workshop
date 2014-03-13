require 'json'

# Understands a specific solution to a rental car offer need
class RentalOfferSolutionDetails
  attr_reader :traits

  def initialize(traits)
    @traits = traits
  end

  def to_json(*args)
    {
      json_class: self.class.name,
      traits: @traits
    }.to_json
  end

  def self.json_create(json_hash)
    new(json_hash['traits'])
  end

end
