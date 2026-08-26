Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "/dashboard", to: "dashboard#show", as: :dashboard

  resources :job_openings, only: [:index, :show] do
    resources :job_applications, only: [:create]
  end

  resources :job_applications, only: [:index, :show, :update, :destroy] do
    post :suggest_tasks, on: :member
    resources :resumes, only: [:create]
  end

  resources :resume, only: [:destroy, :edit, :update] do
    post :recommendations, on: :member
  end

  resources :tasks, only: [:index, :create, :update, :destroy]

  namespace :api do
    get "resumes/callback"
    post "resumes/:id/callback", to: "resumes#callback", as: :resume_callback
  end

end
