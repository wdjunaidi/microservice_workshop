require "bunny"
require "json"
require_relative 'log_packet'
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
    exchange = channel.fanout("rapids", durable: true)
    log_startup(exchange)
    process(channel, exchange)
  rescue Interrupt => _
    channel.close
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def log_startup(exchange)
      exchange.publish(LogPacket.new('info', " [*] Service #{self.class.name} is now operational.").to_json)
    end

    def queue(channel, exchange)
      result = channel.queue("", :exclusive => true)
      result.bind exchange
      result
    end

end
