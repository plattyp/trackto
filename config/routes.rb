Rails.application.routes.draw do
  get 'progresses/create'

  resources :objectives do
  	resources :progresses, only: [:index, :new, :create]
  end
end
