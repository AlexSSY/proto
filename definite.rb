class Builder
  def build &block
    instance_eval(&block)
  end

  
end