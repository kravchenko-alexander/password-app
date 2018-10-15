module Api
  module V1
    module Sessions
      class DestroySessionController < SessionsController
        before_action :authenticate!

        def destroy
          result = ::Sessions::DestroyService.new(session_input).call
          if result.success?
            render_success
          else
            render_error :unprocessable_entity, result.error
          end
        end

        private

        def session_input
          ::Sessions::DestroyService::Input.new do |input|
            input.session = @current_session
          end
        end
      end
    end
  end
end
