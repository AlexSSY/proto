require "ostruct"

class Bot
  class Message
    def initialize user_id, text
      @user_id = user_id
      @text = text
    end

    attr_reader :text

    def from
      user = OpenStruct.new
      user.id = @user_id
    end
  end

  class Api
    def send_message chat_id:, text:
      p "received: #{text}"
    end

    def user id, text
      message = Message.new id, text
      @callback.call message
      p "sended: #{text}"
    end
  end

  def on_update callback
    @callback = callback
  end
end

class Action
  def initialize(proc = nil, filter: nil, &block)
    @proc = proc || block
    @filter = filter
    @data = {}
  end

  attr_accessor :data

  def call(*args, &block)
    result = @proc.call(*args, &block)
    result
  end

  def to_proc
    method(:call).to_proc
  end
end

class Context
  def initialize bot, message
    @bot = bot
    @message = message
  end

  attr_accessor :bot
  attr_reader :message

  def message= value
    @message = value
  end
end

class Builder
  def build &block
    @root_actions = []
    instance_eval(&block)
  end

  def handle filter_callback, &block
    current_actions << Action.new(filtedr: nil) do
      
    end
  end

  def current_actions
    
  end

  def say &block
    current_actions << Action.new do
      bot.api.send_message(chat_id: message.chat.id, text: instance_eval(&block))
    end
  end

  def text_full_lower text
    proc do
      messate_text = message.text
      messate_text.downcase == text.downcase
    end
  end
end

def builder
  builder = Builder.new

  builder.build do
    handle text_full_lower("hi") do
      say { "Hi #{message.from.text}!" }
    end
  end

  builder
end
