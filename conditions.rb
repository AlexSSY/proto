class ConditionValue
  def initialize value
    @value = value
  end

  def eq value, &block
    if @value == value

    end
  end
end

class Context
  def initialize
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
end

class Command
  def execute

  end
end

class DSL
  def initialize
    sessions = []
  end

  def run
  end
end

DSL.rk do
  let(:a) { -1 }
  let(:b) { 0 }
  let(:c) { 1}

  branch(proc { get(:a) < get(:b) }) do
    say "OK"
  end
end