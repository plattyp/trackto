Rails.application.routes.draw do

  devise_for :users

  root 'objectives#index'
  get 'all_progress', to: 'progresses#all_progress'

  resources :objectives do
    resources :progresses, only: [:index, :new, :create]
  end
end
