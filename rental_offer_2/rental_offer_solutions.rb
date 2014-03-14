require "bunny"
require "json"

require_relative 'rabbitmq_binding'
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_details'

# Streams rental-offer-related requests to the console
class RentalOfferSolutions
  include RabbitmqBinding

  alias module_initialize initialize

  def initialize(bus_name, need_instance_id = 'default')
    module_initialize(bus_name)
    @need_instance_id = need_instance_id
    @solutions = {}
  end

  private

    def process(queue, exchange)
      puts " [*] Waiting for needs on the '#{@bus_name}' bus... To exit press CTRL+C"
      queue.subscribe(block: true) do |delivery_info, properties, body|
        process_packet body, exchange
      end
    end

    def process_packet body, exchange
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      packet = JSON.load body
      return if packet.unsatisfied?
      packet.solutions.each { |s| capture s }
      puts " [x] Received #{packet.solutions.size} solution(s). Now have a total of #{@solutions.size} solution(s)."
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def capture(solution)
      @solutions[solution.traits['creative']] = solution.traits['value']
    end

end
