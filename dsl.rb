require "ostruct"
require "telegram/bot"
require "dotenv/load"
require "debug"

class Keyboard
  def initialize
    @rows = []
  end

  def row &block
    @rows << []
    instance_eval(&block)
  end

  def button name
    @rows.last << { text: name }
  end

  def keyboard resize_keyboard: true
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: @rows, resize_keyboard: resize_keyboard)
  end
end

class DSL
  def initialize
    @keyboards = {}
  end

  def config
    c = OpenStruct.new
    yield c
    @config = c
  end

  attr_reader :msg, :bot

  def supply_message message
    @msg = message
    case message
    when Telegram::Bot::Types::Message
      @handlers.each do |handler|
        filter = handler[:filter]
        action = handler[:action]
        if instance_eval(&filter)
          instance_eval(&action)
        end
      end
    end
  end

  def start
    Telegram::Bot::Client.run(@config.token) do |bot|
      @bot = bot
      bot.listen do |message|
        supply_message message
      end
    end
  end

  def handlers &block
    @handlers = []
    instance_eval(&block)
  end

  def handle filter, &block
    @handler = { filter: filter }
    instance_eval(&block)
    @handlers << @handler
    @handler = nil
  end

  def command name
    proc { msg.text == "/#{name.to_s}" }
  end

  def answer keyboard:, &block
    action = proc do
      txt = instance_eval(&block)
      kb = @keyboards[keyboard]
      bot.api.send_message(chat_id: msg.chat.id, text: txt, reply_markup: kb)
    end
    @handler[:action] = action
  end

  def keyboards &block
    instance_eval(&block)
  end

  def reply name, resize: true, &block
    keyboard = Keyboard.new
    keyboard.instance_eval(&block)
    @keyboards[name] = keyboard.keyboard resize_keyboard: resize
  end
end

@dsl = DSL.new

@dsl.config do |c|
  c.token = ENV["BOT_TOKEN"]
end

# @dsl.states do
#   state :animal do |s|
#     s.string :name
#     s.date :birthday
#   end
# end

@dsl.keyboards do
  reply :main do |k|
    k.row do
      button "Home"
      button "List"
    end
  end
end

@dsl.handlers do
  handle command(:start) do
    answer(keyboard: :main) { "Hello #{msg.from.first_name}!" }
  end
end

@dsl.start