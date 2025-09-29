BOT_TOKEN = ""

module Block
  def call(*args, &block)
    result = @proc.call(*args, &block)
    result
  end

  def to_proc
    method(:call).to_proc
  end
end

class Filter
  def initialize type, &block
    @type = type
    @proc = block
  end

  attr_reader :type

  include Block
end

class Message
  def initialize type, data
    @type = type
    @data = data
  end

  attr_reader :type, :data
end

class Context
  def initialize 
    @fiber1 = Fiber.new do
      loop do
        puts "Give me foo:"
        received = Fiber.yield Filter.new("text") { @message.text == "foo" }
        puts received
      end
    end
  end

  def supply_message message
    @message = message
    if @fiber1.alive?

    end
  end
end

class State
end