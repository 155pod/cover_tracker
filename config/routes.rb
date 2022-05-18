Rails.application.routes.draw do
  devise_for :users
  get "/", to: "covers#new"
  get "/success", to: "covers#success"
  post "/upload", to: "covers#create", as: :upload

  get "/admin", to: "covers#index", as: :admin
  get "/admin/archived", to: "covers#index_archived", as: :admin_archived

  get "/player", to: "player#show"

  resources :covers, only: [:update] do
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
