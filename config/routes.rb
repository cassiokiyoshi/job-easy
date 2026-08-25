Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "/dashboard", to: "dashboard#show", as: :dashboard

  resources :job_openings, only: [:index, :show] do
    resources :job_applications, only: [:create]
  end

  resources :job_applications, only: [:index, :show, :update, :destroy ] do
    resources :resumes, only: [:create]
  end

  resources :resumes, only: [:destroy, :edit, :update] do
    post :recommendations, on: :member
  end

  resources :tasks, only: [:create, :update, :destroy]

end
