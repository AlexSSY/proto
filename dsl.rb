require "ostruct"
require "telegram/bot"
require "dotenv/load"
require "debug"

class Compare
  def initialize value
    @value = value
  end

  def ne value
    
  end

  def ge value
    
  end
end

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
        actions = handler[:actions]
        if instance_eval(&filter)
          actions.each { |action| instance_eval(&action) }
          return
        end
      end
    end
  end

  def start
    bot = Telegram::Bot::Client.new(@config.token)
    @bot = bot

    Signal.trap('INT') do
      bot.stop
    end

    bot.listen do |message|
      supply_message message
    end
  end

  def handlers &block
    @handlers = []
    @states = {}
    instance_eval(&block)
  end

  def handle filter, &block
    @handler = { filter: filter }
    @action_list = []
    instance_eval(&block)
    @handler[:actions] = @action_list
    @handlers << @handler
    @action_list = nil
    @handler = nil
  end

  def handle_state name, &block
    @handler = { filter: proc { @states[msg.from.id] == name } }
    @action_list = []
    @action_list << proc do
      instance_variable_set "@#{@states[msg.from.id].to_s}", msg.text
      define_singleton_method(@states[msg.from.id]) do
        instance_variable_get "@#{@states[msg.from.id].to_s}"
      end
    end
    instance_eval(&block)
    @action_list << proc { @states[msg.from.id] = nil }
    @handler[:actions] = @action_list
    @handlers << @handler
    @action_list = nil
    @handler = nil
  end

  def command name
    proc { msg.text == "/#{name.to_s}" }
  end

  def text
    proc { true }
  end

  def the name
    value = send(name)
    Compare.new(value)
  end

  def ne prc
    
  end

  def answer keyboard_name: false, &block
    @action_list << proc do
      txt = instance_eval(&block)
      if keyboard_name
        kb = @keyboards[keyboard_name]
        bot.api.send_message(chat_id: msg.chat.id, text: txt, reply_markup: kb)
      else
        bot.api.send_message(chat_id: msg.chat.id, text: txt)
      end
    end
  end

  def recv state
    @action_list << proc { @states[msg.from.id] = state }
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
    answer(keyboard_name: :main) { "Hello #{msg.from.first_name}!" }
    answer { "Enter please your age:" }
    recv :age
  end

  handle text, state: :age do
    the(:age).ne(18) do
      answer { "Great (#{msg.from.first_name}) your age: #{age}" }
    end

    the(:age).ge(18) do
      answer { "Sad (#{msg.from.first_name}) your age: #{age}" }
    end
  end
end

@dsl.start