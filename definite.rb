class Context
  def initialize runner, bot, message
    @runner = runner
    @bot = bot
    @message = message
  end

  attr_reader :bot, :message, :runner

  def supply_message message
    @message = message
  end
end

class Runner
  def push_one_time_handler filter, context
    
  end
end
