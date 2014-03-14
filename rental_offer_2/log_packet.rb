require 'json'

# Understands status of a service
class LogPacket

  attr_reader :severity   # info, warning, error
  attr_reader :message

  def initialize(severity = 'info', message = '')
    @severity, @message = severity, message
  end

  def to_json(*args)
    {
      json_class: self.class.name,
      severity: @severity,
      message: @message
    }.to_json
  end

  def self.json_create(json_hash)
    new(json_hash['severity'], json_hash['message'])
  end

end
