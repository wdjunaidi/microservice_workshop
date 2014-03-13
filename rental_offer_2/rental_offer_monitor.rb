require "bunny"
require "json"

require_relative 'consumer'
require_relative 'rental_offer_need_packet'

# Streams rental-offer-related requests to the console
class RentalOfferMonitor
  include Consumer

  private

    def process body, ignore
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      puts " [x] Need for '#{content['need']}' expressed by '#{content['need_instance_id']}'. #{solutions_message(content)}"
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def solutions_message(content)
      solutions = content['solutions']
      return 'No solutions (yet!)' if solutions.nil? || solutions.empty?
      "#{solutions.size} solution(s) proposed."
    end

end
