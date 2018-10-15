module Api
  module V1
    module Registrations
      class UpdateRegistrationController < RegistrationsController
        before_action :authenticate!

        def update
          result = ::Registrations::UpdateService.new(registration_input).call
          if result.success?
            render_success
          else
            render_error :unprocessable_entity, result.error
          end
        end

        private

        def user_params
          @user_params ||= params.require(:user).permit(:current_password,
                                                        :password,
                                                        :password_confirmation)
        end

        def registration_input
          ::Registrations::UpdateService::Input.new do |input|
            input.current_password = user_params[:current_password]
            input.password = user_params[:password]
            input.password_confirmation = user_params[:password_confirmation]
            input.user = @current_user
          end
        end
      end
    end
  end
end
