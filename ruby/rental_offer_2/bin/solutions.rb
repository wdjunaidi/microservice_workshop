#!/usr/bin/env ruby
# encoding: utf-8

if ARGV.empty?
  puts "Format is: \n  solutions <vhost> [<need_instance_id>]"
  exit 2
end

require_relative '../rental_offer_solutions'

options = {}
bus_name = ARGV.shift
[:need_instance_id].each do |var|  # Options in this order
  break if ARGV.empty?
  options[var] = ARGV.shift
end

RentalOfferSolutions.new(bus_name, options).start
