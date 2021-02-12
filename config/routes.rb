Rails.application.routes.draw do
  get "/", to: "covers#new"
  post "/upload", to: "covers#create", as: :upload
end
