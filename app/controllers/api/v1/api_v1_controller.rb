module Api
  module V1
    class ApiV1Controller < ApiController
      rescue_from ActiveRecord::RecordNotFound,       with: :not_found_error
      rescue_from ArgumentError,                      with: :argument_error
      rescue_from ActionController::ParameterMissing, with: :parameter_missing_error
      # rescue_from NoMethodError,                      with: :no_method_error

      private

      def render_success(message = nil)
        if message.nil?
          head :ok
        else
          render json: { message: message }, status: :ok
        end
      end

      def render_error(status, message)
        render json: { error: message }, status: status
      end

      def not_found_error(error)
        render_error :not_found, error.message
      end

      def argument_error(error)
        render_error :unprocessable_entity, error.message
      end

      def parameter_missing_error(error)
        render_error :unprocessable_entity, error.message
      end

      def authenticate!
        result = ::Sessions::AuthorizeService.new(
          ::Sessions::AuthorizeService::Input.new do |input|
            input.access_token = request.headers['Access-Token']
          end
        ).call
        if result.success?
          @current_session = result.session
          @current_user = result.user
        else
          render_error :unauthorized, result.error
        end
      end

      def create_response_auth_headers(session)
        response.headers['Access-Token'] = session.access_token
        response.headers['Access-Token-Expired-At'] =
          session.access_token_expired_at
        response.headers['Refresh-Token'] = session.refresh_token
        response.headers['Refresh-Token-Expired-At'] =
          session.refresh_token_expired_at
      end
    end
  end
end
