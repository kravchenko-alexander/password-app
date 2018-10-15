module Result
  class Failure < Result::Base
    def failure?
      true
    end

    def success?
      false
    end
  end
end
