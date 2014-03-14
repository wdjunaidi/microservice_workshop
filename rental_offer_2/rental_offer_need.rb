require "bunny"
require_relative "rental_offer_need_packet"

# Expresses a need for rental car offers
class RentalOfferNeed
  HOST = 'microserver.local'
  DEFAULT_OPTIONS = {
    interval_in_seconds: 0,   # Interval to wait prior re-broadcasting need (0 = don't re-broadcast)
    need_instance_id: 'unknown'
  }

  def initialize(bus_name, options = {})    # Options include :interval_in_seconds
    options = DEFAULT_OPTIONS.merge options
    @bus_name = bus_name
    @interval_in_seconds = options[:interval_in_seconds].to_i
    @need_instance_id = options[:need_instance_id]
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
    publish_needs(exchange)
  rescue Interrupt => _
    channel.close
    puts "\n [*] Ceased expressing needs!"
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def publish_needs(exchange)
      puts " [*] Expressing need on the '#{@bus_name}' bus... To exit press CTRL+C" unless @interval_in_seconds == 0
      while true
        exchange.publish(RentalOfferNeedPacket.new(@need_instance_id).to_json)
        puts " [x] Published a rental offer need on the '#{@bus_name}' bus"
        break if @interval_in_seconds == 0
        sleep @interval_in_seconds
      end
    end

end
