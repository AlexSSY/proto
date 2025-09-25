class Message
  def initialize text, from
    @text = text
    @from = from
  end

  attr_reader :text, :from
end


class Server
  def send id, text
    @onrecv_block.call Message.new text, id if @onrecv_block
  end

  def answer id, text
    @onsend_block.call Message.new text, id if @onsend_block
  end

  def onrecv &block
    @onrecv_block = block
  end

  def onsend &block
    @onsend_block = block
  end
end


class Step
  def initialize need_wait = false, &block
    @block = block
    @need_wait = need_wait
    @prev = @next = nil
  end

  attr_accessor :prev, :next
end


class RealStep
  def initialize step
    @step = step
  end
end


class Context
  def initialize message
    @__message = message
    @__vars = {}
  end

  def let name, &block
    @__vars[name] = instance_eval(&block)
  end

  def get name
    @__vars[name]
  end

  def set name, &block
    len name, &block
  end

  def message
    @__message
  end

  def message= message
    @__message = message
  end
end


class Engine
  def initialize
    @session = {}
    @session[]
  end

  def scenario
    step1 = Step.new { puts "enter name:" }
    step2 = Step.new(true) { set(:name, message.text) }
    step3 = Step.new { puts "your name: #{get(:name)}" }
    step1.next = step2
    step2.prev = step1
    step2.next = step3
    step3.prev = step2
    step1
    Proc.new do
      server.send 456, "enter name:"
      new_message = Fiber.yield
      server.send 456, "your name: #{mew_message}"
    end
  end

  def update message
    if message.text == '/start'
      @session << scenario
    end
  end
end
