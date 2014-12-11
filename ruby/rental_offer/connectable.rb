require_relative 'connection'

module Connectable

  def start(host, bus_name)
    @host = host
    @bus_name = bus_name
    Connection.with_open(@host, @bus_name) { |ch, ex| connection_handler(ch, ex) } 
  end

  def connection_handler(channel, exchange)
    fail NotImplementedError, "Connectable must implement connection_handler(channel, exchange)"
  end
end
