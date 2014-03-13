require "bunny"
require "json"
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution'

# Streams rental-offer-related requests to the console
class AwarenessOffer
  HOST = 'microserver.local'

  def initialize(bus_name)
    @bus_name = bus_name
  end

  def start
    conn = Bunny.new(
        user: @bus_name,
        password: @bus_name,
        vhost: @bus_name,
        host: HOST,
        automatically_recover: false)
    conn.start
    channel = conn.create_channel
    monitor_needs(channel)
  rescue Interrupt => _
    channel.close
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def monitor_needs(channel)
      queue = channel.queue("", :exclusive => true)
      exchange = channel.fanout("rapids", durable: true)
      queue.bind exchange
      puts " [*] Waiting for needs on the '#{@bus_name}' bus... To exit press CTRL+C"
      queue.subscribe(block: true) do |delivery_info, properties, body|
        process body, exchange
      end
    end

    def process body, exchange
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      packet = JSON.load body
      return unless packet.unsatisfied?
      packet.propose_solution awareness_solution
      exchange.publish packet.to_json
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def awareness_solution
      RentalOfferSolution.new(creative: 'awareness_1.jpg', value: 20, type: 'awareness')
      puts " [x] Proposed solution with creative 'awareness_1'"
    end

end
