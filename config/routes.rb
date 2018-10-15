Rails.application.routes.draw do
  mount Raddocs::App => '/api/docs'

  namespace :api do
    namespace :v1 do
      post 'registrations' => 'registrations/create_registration#create'
      put 'registrations' => 'registrations/update_registration#update'

      post 'sessions' => 'sessions/create_session#create'
      delete 'sessions' => 'sessions/destroy_session#destroy'
      put 'sessions' => 'sessions/update_session#update'

      post 'password_sets' => 'password_sets/create_password_set#create'
      get 'password_sets/:encrypted_token' => 'password_sets/show_password_set#show'

      get 'password_views/:encrypted_token' => 'password_views/index_password_views#index'
    end
  end
end
