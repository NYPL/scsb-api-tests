require 'rainbow'

class Logger
  def self.debug(message)
    return if (ENV['LOG_LEVEL'] || '').downcase != 'debug'

    puts Rainbow(message).blue
  end
end
