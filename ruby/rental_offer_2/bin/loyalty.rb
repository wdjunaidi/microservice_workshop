#!/usr/bin/env ruby
# encoding: utf-8


if ARGV.empty?
  puts "Format is: \n  awareness <vhost>"
  exit 2
end

require_relative '../join_loyalty_offer'

JoinLoyaltyOffer.new(ARGV.shift).start
