#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'rental_offer_need_packet'
require_relative 'connectable'

# Expresses a need for rental car offers
class RentalOfferNeed

  include Connectable

  private

  def connection_handler(channel, exchange)
    publish_need(channel, exchange)
  end

  def publish_need(channel, exchange)
    exchange.publish RentalOfferNeedPacket.new.to_json
    puts " [x] Published a rental offer need on the #{@bus_name} bus"
  end

end

RentalOfferNeed.new().start(ARGV.shift, ARGV.shift)
