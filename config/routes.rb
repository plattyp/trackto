Rails.application.routes.draw do

  root 'objectives#index'

  resources :objectives do
    resources :progresses, only: [:index, :new, :create]
  end
end
