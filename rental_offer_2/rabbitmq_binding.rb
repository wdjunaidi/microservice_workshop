require "bunny"
require "json"
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_details'

# Streams rental-offer-related requests to the console
module RabbitmqBinding
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
    queue = channel.queue("", :exclusive => true)
    exchange = channel.fanout("rapids", durable: true)
    queue.bind exchange
    process(queue, exchange)
  rescue Interrupt => _
    channel.close
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def process(queue, exchange)
      puts " [*] Waiting for needs on the '#{@bus_name}' bus... To exit press CTRL+C"
      queue.subscribe(block: true) do |delivery_info, properties, body|
        process body, exchange
      end
    end

end
