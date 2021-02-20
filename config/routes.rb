Rails.application.routes.draw do
  get "/", to: "covers#new"
  get "/success", to: "covers#success"
  post "/upload", to: "covers#create", as: :upload

  get "/admin", to: "covers#index", as: :admin
  get "/admin/archived", to: "covers#index_archived", as: :admin_archived

  resources :covers, only: [:update] do
    member do
      post :archive
      post :unarchive
    end
    collection do
      post :archive_all
    end
  end
end
