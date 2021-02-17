Rails.application.routes.draw do
  get "/", to: "covers#new"
  get "/success", to: "covers#success"
  post "/upload", to: "covers#create", as: :upload

  get "/admin", to: "covers#index", as: :admin

  resources :covers, only: [:update] do
    member do
      post :archive
    end
    collection do
      post :archive_all
    end
  end
end
