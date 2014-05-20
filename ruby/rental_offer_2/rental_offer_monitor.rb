require "bunny"
require "json"

require_relative 'rabbitmq_binding'
require_relative 'rental_offer_need_packet'

# Streams rental-offer-related requests to the console
class RentalOfferMonitor
  include RabbitmqBinding

  private

    def process(channel, exchange)
      puts " [*] Waiting for needs on the '#{@bus_name}' bus... To exit press CTRL+C"
      queue(channel, exchange).subscribe(block: true) do |delivery_info, properties, body|
        process_packet body, exchange
      end
    end

    def process_packet body, ignore
      content = JSON.parse body
      return puts(" [x] Message: #{body}") unless content['need'] == RentalOfferNeedPacket::NEED
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
