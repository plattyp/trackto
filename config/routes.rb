Rails.application.routes.draw do
  get 'progresses/create'

  resources :objectives do
  	resources :progresses, only: [:new, :create]
  end
end
