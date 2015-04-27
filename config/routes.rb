Rails.application.routes.draw do

  devise_for :users

  root 'objectives#index'
  get 'all_progress', to: 'progresses#all_progress'

  devise_for :users, :skip => [:sessions, :registrations, :passwords]
  devise_scope :user do
    post 'login' => 'sessions#create', :as => :login
    delete 'logout' => 'sessions#destroy', :as => :logout
    post 'register' => 'registrations#create', :as => :register
    delete 'delete_account' => 'registrations#destroy', :as => :delete_account
  end

  resources :objectives do
    resources :progresses, only: [:index, :new, :create]
  end
end
