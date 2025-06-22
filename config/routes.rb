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
    resources :medication_group_invitations, shallow: true
  end

  # 招待URL専用（トークンベース）
  get "invite/:token", to: "medication_group_invitations#show", as: :medication_group_invitation_token
  patch "invite/:token", to: "medication_group_invitations#accept", as: :accept_medication_group_invitation_token

  if Rails.env.development?
    require "sidekiq/web"
    require "sidekiq-scheduler/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  # lineのWebhook
  post "/callback", to: "line_bot#callback"
end
