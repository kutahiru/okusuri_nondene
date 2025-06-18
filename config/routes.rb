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
    resources :medication_group_users, shallow: true
  end

  if Rails.env.development?
    require "sidekiq/web"
    require "sidekiq-scheduler/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end
