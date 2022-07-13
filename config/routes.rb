Rails.application.routes.draw do
  devise_for :users
  get "/", to: "submissions#new"
  get "/success", to: "submissions#success"
  post "/upload", to: "submissions#create", as: :upload

  get "/admin", to: "submissions#index", as: :admin
  get "/admin/archived", to: "submissions#index_archived", as: :admin_archived

  get "/player", to: "player#show"

  resources :submissions, only: [:update] do
    member do
      post :archive
      post :unarchive
      post :toggle_b_side

      get :artwork
    end
    collection do
      post :archive_all
      post :update_order
    end
  end
end
