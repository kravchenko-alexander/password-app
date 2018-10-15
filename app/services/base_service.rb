class BaseService
  class << self
    def call(*args, &block)
      new(*args, &block).call
    end
  end
end
