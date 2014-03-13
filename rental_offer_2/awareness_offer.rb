require "bunny"
require "json"

require_relative 'consumer'
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_details'

# Streams rental-offer-related requests to the console
class AwarenessOffer
  include Consumer

  private

    def process body, exchange
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      packet = JSON.load body
      return unless packet.unsatisfied?
      awareness_solutions.each { |s| packet.propose_solution s}
      exchange.publish packet.to_json
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def awareness_solutions
      puts " [x] Proposed solution with creative 'awareness_1' and 'join_renters_club_1'"
      [
        RentalOfferSolutionDetails.new(creative: 'awareness_1.jpg', value: 20, type: 'awareness'),
        RentalOfferSolutionDetails.new(creative: 'join_renters_club_1.jpg', value: 40, type: 'join_renters_club')
      ]
    end

end
