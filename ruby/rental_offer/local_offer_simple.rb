#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connection'
require 'json'

# Streams rental-offer-related requests to the console
class LocalOfferSimple

  def initialize(host, bus_name)
    @host = host
    @bus_name = bus_name
  end

  def start
    Connection.with_open(@host, @bus_name) {|ch, ex| brand_offer_solutions(ch, ex) }
  end

private

  def brand_offer_solutions(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for need on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"
      need = JSON.parse body
      if need['solutions'].size == 0 
        if need['location']
          need['solutions'] << {:json_class => 'LocalOfferSimple', :offer => '10%-off', :value => rand(100) }
          need_json = JSON.generate need
          puts " [>] Respond with #{need_json}"
          exchange.publish need_json
        else
          need['solutions'] << {:json_class => 'LocalOfferSimple', :offer => '5%-off Next Rental', :value => 15 }
          need_json = JSON.generate need
          puts " [>] Respond with #{need_json}"
          exchange.publish need_json
        end
      end
    end
  end

end

LocalOfferSimple.new(ARGV.shift, ARGV.shift).start
