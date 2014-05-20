#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

# Streams rental-offer-related requests to the console

# TODO: Parameterize the host variable
class RentalOfferMonitor
  # HOST = 'microserver.local'
  HOST = 'localhost'

  def initialize(bus_name)
    @bus_name = bus_name
  end

  def start
    begin
      puts "Opening connection to RabbitMQ host..."
      conn = Bunny.new(
                       user: @bus_name,
                       password: @bus_name,
                       vhost: @bus_name,
                       host: HOST,
                       automatically_recover: false)
      conn.start
      channel = conn.create_channel
      monitor_solutions(channel)
    rescue Interrupt
      channel.close
    rescue Exception => ex
      puts ex
    ensure
      conn.close if conn
    end
  end

  private

  def monitor_solutions(channel)
    queue = channel.queue("", :exclusive => true)
    exchange = channel.fanout("rapids", durable: true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"
    end
  end

end

RentalOfferMonitor.new(ARGV.shift).start
