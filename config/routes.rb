Rails.application.routes.draw do
  resources :series
  resources :serials
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'series#lastweek'
  get 'serials', to: 'serials#index'
  get 'tracked', to: 'serials#tracked'
  post '/services/track', to: 'serials#track'
  post '/services/check', to: 'serials#check'
  post '/services/download', to: 'series#download'
  get '/episodes/lastweek', to: 'series#lastweek'
  post '/services/play', to: 'series#play'
  get '/services/add_full_serial', to: 'series#add_full_serial'
  post '/services/download_full_serial', to: 'series#download_full_serial'

  
end
