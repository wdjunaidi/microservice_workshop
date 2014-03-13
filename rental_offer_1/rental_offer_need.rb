#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require_relative "rental_offer_need_packet"

# Expresses a need for rental car offers
class RentalOfferNeed

  def initialize(bus_name)
    @bus_name = bus_name
  end

  def start
    conn = Bunny.new(
        user: @bus_name,
        password: @bus_name,
        vhost: @bus_name,
        automatically_recover: false)
    conn.start
    channel = conn.create_channel
    exchange = channel.fanout("rapids", durable: true)
    publish_needs(exchange)
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def publish_needs(exchange)
      exchange.publish(RentalOfferNeedPacket.new.to_json)
      puts " [x] Published a rental offer need on the #{@bus_name} bus"
    end

end

bus_name = ARGV.shift
RentalOfferNeed.new(bus_name).start
