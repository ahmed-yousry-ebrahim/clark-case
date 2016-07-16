Rails.application.routes.draw do

  scope :api, defaults: { format: :json } do
    namespace :v1 do
      resources :posts, except: [:new, :edit] do
        member do
          get :toggle_like
        end
        resources :comments, except: [:new, :edit] do
          member do
            get :toggle_like
          end
        end
      end
    end
  end

  mount_devise_token_auth_for 'User', at: '/api/v1/auth'

end
