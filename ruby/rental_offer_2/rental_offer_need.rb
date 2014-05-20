require "bunny"
require_relative "rabbitmq_binding"
require_relative "rental_offer_need_packet"

# Expresses a need for rental car offers
class RentalOfferNeed
  include RabbitmqBinding

  DEFAULT_OPTIONS = {
    interval_in_seconds: 0,   # Interval to wait prior re-broadcasting need (0 = don't re-broadcast)
    need_instance_id: 'unknown'
  }

  alias module_initialize initialize

  def initialize(bus_name, options = {})    # Options include :interval_in_seconds
    module_initialize(bus_name)
    options = DEFAULT_OPTIONS.merge options
    @interval_in_seconds = options[:interval_in_seconds].to_i
    @need_instance_id = options[:need_instance_id]
  end

  private

    def process(ignore, exchange)
      puts " [*] Expressing need on the '#{@bus_name}' bus... To exit press CTRL+C" unless @interval_in_seconds == 0
      while true
        exchange.publish(RentalOfferNeedPacket.new(@need_instance_id).to_json)
        puts " [x] Published a rental offer need on the '#{@bus_name}' bus"
        break if @interval_in_seconds == 0
        sleep @interval_in_seconds
      end
    end

end
