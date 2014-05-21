#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connection'

# Streams rental-offer-related requests to the console
class RentalOfferMonitor

  def initialize(host, bus_name)
    @host = host
    @bus_name = bus_name
  end

  def start
    Connection.with_open(@host, @bus_name) {|ch, ex| monitor_solutions(ch, ex) }
  end

private

  def monitor_solutions(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"
    end
  end

end

RentalOfferMonitor.new(ARGV.shift, ARGV.shift).start
