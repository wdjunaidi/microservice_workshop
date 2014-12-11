#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connectable'
require 'json'

# Streams rental-offer-related requests to the console
class UserSolutions
  include Connectable

  def initialize
    @solutions = Hash.new
  end

private

  def connection_handler(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the '#{@bus_name}' bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      need = JSON.parse body
      puts " [x] Received need - #{body}"
      if need['solutions'].size > 0
        need['user'] ||= 'unknown user'
        if (@solutions.has_key?(need['user']) && @solutions[need['user']])
          @solutions[need['user']] = better_solution(@solutions[need['user']], need['solutions'][0])
        else
          @solutions[need['user']] = need['solutions'][0]
        end
        puts " [>] Best solution: #{@solutions[need['user']]}"
      else
        puts " [^] No solution, continue to wait..."
      end
    end
  end

  def better_solution(opt_1, opt_2)
    opt_1['profit'] > opt_2['profit'] ? opt_1 : opt_2
  end

end

UserSolutions.new().start(ARGV.shift, ARGV.shift)
