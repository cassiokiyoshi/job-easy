Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/settings", to: "devise/registrations#edit", as: :settings
  end
  root to: "pages#home"

  get "/dashboard", to: "dashboard#show", as: :dashboard

  resources :job_openings, only: [:index, :show] do
    resources :job_applications, only: [:create]
  end

  resources :job_applications, only: [:index, :show, :update, :destroy] do
    post :suggest_tasks, on: :member
    resources :resumes, only: [:create]
  end

  resources :resumes, only: [:destroy, :edit, :update] do
    post :recommendations, on: :member
  end

  resources :tasks, only: [:index, :create, :update, :destroy]

  namespace :api do
    get "resumes/callback"
    post "resumes/:id/callback", to: "resumes#callback", as: :resume_callback
  end

end
