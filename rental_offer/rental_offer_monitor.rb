#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

# Streams rental-offer-related requests to the console
class RentalOfferMonitor

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
    monitor_solutions(channel)
  rescue Interrupt => _
    channel.close
  ensure
    conn.close if conn
    exit(0)
  end

  private

    def monitor_solutions(channel)
      queue = channel.queue("", :exclusive => true)
      exchange = channel.fanout("rapids", durable: true)
      queue.bind exchange
      puts " [*] Waiting for solution... To exit press CTRL+C"
      queue.subscribe(block: true) do |delivery_info, properties, body|
        process body
      end
    end

    def process body
      puts " [x] #{body}"
    end

end

RentalOfferMonitor.new('booboo').start
