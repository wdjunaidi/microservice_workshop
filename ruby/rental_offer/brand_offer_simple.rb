#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connectable'
require 'json'

# Streams rental-offer-related requests to the console
class BrandOfferSimple
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
        need['solutions'] << {:chance => rand(100), :name => '5%-off', :profit => rand(10000) }
        need_json = JSON.generate need
        puts " [>] Respond with #{need_json}"
        exchange.publish need_json
      end
    end
  end

end

BrandOfferSimple.new().start(ARGV.shift, ARGV.shift)
