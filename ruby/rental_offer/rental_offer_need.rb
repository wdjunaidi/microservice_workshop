#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'rental_offer_need_packet'
require_relative 'connectable'

# Expresses a need for rental car offers
class RentalOfferNeed

  include Connectable

  def initialize(user, location)
    @user_name = user
    @location = location
  end

private

  def connection_handler(channel, exchange)
    packet = @location ? RentalOfferNeedPacket.new(@user_name, @location) : RentalOfferNeedPacket.new(@user_name)
    exchange.publish packet.to_json
    puts " [x] Published a rental offer need from #{@user_name} on the #{@bus_name} bus"
  end

end

RentalOfferNeed.new(ARGV.shift, ARGV.shift).start(ARGV.shift, ARGV.shift)
