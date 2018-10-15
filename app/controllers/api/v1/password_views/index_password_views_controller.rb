module Api
  module V1
    module PasswordViews
      class IndexPasswordViewsController < PasswordViewsController
        before_action :authenticate!

        def index
          result = ::PasswordViews::GetListService.new(password_view_input).call
          if result.success?
            render 'api/v1/password_views/index',
                   locals: { password_views: result.password_views },
                   status: :ok
          else
            render_error :forbidden, result.error
          end
        end

        private

        def password_params
          params.require(:encrypted_token)
        end

        def password_view_input
          ::PasswordViews::GetListService::Input.new do |input|
            input.encrypted_token = password_params
            input.user = @current_user
            input.page = page
          end
        end

        def page
          params[:page].to_i == 0 ? 1 : params[:page].to_i
        end
      end
    end
  end
end
