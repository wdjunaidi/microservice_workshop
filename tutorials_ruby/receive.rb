#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

conn = Bunny.new("amqp://guest:guest@microserver.local:5672")
conn.start

ch   = conn.create_channel
q    = ch.queue("hello")

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] Received #{body}"
  end
rescue Interrupt => _
  conn.close

  exit(0)
end
