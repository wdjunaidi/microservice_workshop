#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connectable'
require 'json'

# Streams rental-offer-related requests to the console
class LocalOfferSimple
  include Connectable

private

  def connection_handler(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for need on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"
      need = JSON.parse body
      if need['solutions'].size == 0
        need['location'] ? location_offer(need, exchange) : no_location_offer(need, exchange)
      end
    end
  end

  def location_offer(need, exchange) 
    membership = need['membership'] ? need['membership'] : 'default'
    name = ''

    case membership.downcase
    when 'silver' 
      name = '12.5%-off Silver'
    when 'gold'   
      name = '15%-off Gold'
    when 'platinum' 
      name = '20%-off Platinum'
    else 
      name = '10%-off'
    end

    need['solutions'] << {:chance => rand(100), :name => name, :profit => rand(10000) }
    need_json = JSON.generate need
    puts " [>] Respond with #{need_json}"
    exchange.publish need_json
  end

  def no_location_offer(need, exchange)
    need['solutions'] << {:chance => 15, :name => '10%-off', :profit => 125 }
    need_json = JSON.generate need
    puts " [>] Respond with #{need_json}"
    exchange.publish need_json
  end

end

LocalOfferSimple.new().start(ARGV.shift, ARGV.shift)
