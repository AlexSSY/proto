BOT_TOKEN = ""

@fiber1 = Fiber.new do
  loop do
    puts "Fiber started."
    Fiber.yield(proc { message.type == "text" && /d+/.match(message.text) })
  end
end