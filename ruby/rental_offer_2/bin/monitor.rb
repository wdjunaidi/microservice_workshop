#!/usr/bin/env ruby
# encoding: utf-8

if ARGV.empty?
  puts "Format is: \n  monitor <vhost>"
  exit 2
end

require_relative '../rental_offer_monitor'

RentalOfferMonitor.new(ARGV.shift).start
