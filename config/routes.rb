Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do

  root 'objectives#index'
  get 'all_progress', to: 'progresses#all_progress'

  devise_for :users

    devise_for :users, :skip => [:sessions, :registrations, :passwords]
    devise_scope :user do
      post 'login' => 'sessions#create', :as => :login
      delete 'logout' => 'sessions#destroy', :as => :logout
      post 'register' => 'registrations#create', :as => :register
      delete 'delete_account' => 'registrations#destroy', :as => :delete_account
    end

    get '/progress_overview' => "objectives#progress_overview", as: "progress_overview"
    get '/objectives_overview' => "objectives#objectives_overview", as: "objectives_overview"

    resources :objectives do
      post '/archive' => "objectives#archive", as: "archive"
      post '/unarchive' => "objectives#unarchive", as: "unarchive"
      resources :subobjectives, only: [:index, :new, :create]
      resources :progresses, only: [:index, :new, :create]
    end

    resources :subobjectives do
      resources :progresses, only: [:new, :create]
    end

    resources :subobjectives, only: [:destroy]
  end
end
