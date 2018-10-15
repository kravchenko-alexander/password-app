module Sessions
  class DestroyService < BaseService
    class Input < Struct.new(:session)
      def initialize(*attributes)
        super
        yield self
        freeze
      end
    end

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      input.session.destroy!

      ::Result::Success.new
    end
  end
end
