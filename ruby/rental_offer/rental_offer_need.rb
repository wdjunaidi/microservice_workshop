#!/usr/bin/env ruby
# encoding: utf-8

# Docker run command:
#   docker run --name='need' -it -v /c/Users/fred/src/microservice_workshop/ruby:/workshop -w /workshop/rental_offer fredgeorge/ruby_microservice bash
# To run monitor at prompt:
#   ruby rental_car_need.rb 192.168.59.103 bugs

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
