#!/usr/bin/env ruby
# encoding: utf-8

require_relative '../rental_offer_monitor'

RentalOfferMonitor.new(ARGV.shift).start
