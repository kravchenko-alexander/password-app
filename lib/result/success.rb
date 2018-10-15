module Result
  class Success < Result::Base
    def failure?
      false
    end

    def success?
      true
    end
  end
end
