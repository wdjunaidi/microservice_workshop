#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connectable'

# Streams rental-offer-related requests to the console
class RentalOfferMonitor

  include Connectable
private

  def connection_handler(channel, exchange)
    monitor_solutions(channel, exchange)
  end

  def monitor_solutions(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"
    end
  end

end

RentalOfferMonitor.new().start(ARGV.shift, ARGV.shift)
