Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users

  resources :posts do
    resources :comments, only: [:create]

    member do
      get 'download', to: 'posts#download'
    end
  end

  #tylko zalogowani użytkownicy-admini mają dostęp do panelu administratora
  authenticate :user, ->(u) { u.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  devise_scope :user do
    get 'users/sign_out', to: 'public#home'  # Przekierowanie na stronę główną po wylogowaniu
  end

  # Defines the root path route ("/")
  root "public#home"
end
