Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
    
    root 'objectives#index'
    get 'all_progress', to: 'progresses#all_progress'
    get '/progress_overview' => "objectives#progress_overview", as: "progress_overview"
    get '/objectives_overview' => "objectives#objectives_overview", as: "objectives_overview"
    get '/subobjectives_today' => "objectives#subobjectives_today", as: "subobjectives_today"

    resources :objectives do
      post '/archive' => "objectives#archive", as: "archive"
      post '/unarchive' => "objectives#unarchive", as: "unarchive"
      get '/progress_trend' => "objectives#progress_trend_for_objective", as: 'progress_trend'
      resources :progresses, only: [:index, :create]
    end

    resources :subobjectives do
      post 'add_progress' => "subobjectives#add_progress", as: "add_progress"
      resources :progresses, only: [:new, :create]
    end

    resources :subobjectives, only: [:destroy]
  end
end
