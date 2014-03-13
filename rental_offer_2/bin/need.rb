#!/usr/bin/env ruby
# encoding: utf-8

if ARGV.empty?
  puts "Format is: \n  need <vhost> [<interval_in_seconds> [<need_instance_id>] ]"
  exit 2
end

require_relative '../rental_offer_need'

options = {}
bus_name = ARGV.shift
[:interval_in_seconds, :need_instance_id].each do |var|  # Options in this order
  break if ARGV.empty?
  options[var] = ARGV.shift
end

RentalOfferNeed.new(bus_name, options).start
