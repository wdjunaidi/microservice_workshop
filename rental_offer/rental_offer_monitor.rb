#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "json"
require_relative 'rental_offer_need_packet'

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
      puts " [*] Waiting for solutions on the #{@bus_name} bus... To exit press CTRL+C"
      queue.subscribe(block: true) do |delivery_info, properties, body|
        process body
      end
    end

    def process body
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      puts " [x] Need for #{content['need']} expressed. #{solutions_message(content)}"
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def solutions_message(content)
      return 'No solutions (yet!)' if content['solutions'].nil?
      solutions = JSON.parse(content['solutions'])
      return 'No solutions (yet!)' if solutions.empty?
      "Proposing #{solutions.size} solutions."
    end

end

RentalOfferMonitor.new('booboo').start
