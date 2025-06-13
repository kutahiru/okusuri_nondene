Rails.application.routes.draw do
  root "home#top"

  devise_for :users, controllers: {
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    delete "logout", to: "users/sessions#destroy", as: :logout
  end

  resources :medication_groups do
    resources :medication_schedules, shallow: true
  end
end
