CookbookHeritage::Application.routes.draw do

  # Pages
  get "faq", to: "pages#faq", as: "faq"

  get "login", to: "sessions#new", as: "login"
  get "logout", to: "sessions#destroy", as: "logout"
  get "session_expiry_time", to: "sessions#testing"
  resources :sessions

  resources :cookbooks do
    member do
      get :select
      put :update_attachment
      get :edit_introduction
      put :update_introduction
      put :update_introduction_attachment
      get :edit_title
      put :update_title
      get :preview
      get :preview_cover
      get :preview_title_and_toc
      get :preview_index
      get :preview_introduction
      get :check_price
      get :count_page
    end
  end

  get "signup", to: "accounts#new", as: "signup"
  get "recover_password", to: "accounts#recover_password", as: "recover_password"
  post "new_password", to: "accounts#new_password", as: "new_password"
  resources :accounts do
    member do 
      get  :edit_password
      put  :update_password
      get  "upgrade/(:plan_id)", to: "accounts#upgrade", as: "upgrade"
      get  :edit_additional_information
      put  :update_additional_information
      post :process_payment
      get  :payment_processed
    end
  end

  resources :lib_images do
    member do
      get :select
    end
  end

  resources :templates do
    member do
      get :select
    end
  end

  resources :contributors do
    member do
      get :resend_invite
    end
  end

  resources :sections do
    collection do
      post :sort
    end
    resources :recipes do
      member do
        get :preview
        put :update_attachment
        post :update_attachment
      end
    end
    resources :extra_pages do
      member do
        get :preview
        put :update_attachment
      end
    end
    member do
      get :preview
      put :update_attachment
    end
  end
  
  resources :orders do
    member do 
      get :ask_price_quote
      get :edit_customer_details
      put :update_customer_details
      get :confirm
      post :create_price_quote
      get :approved
      get :declined
      get :notify_binding_problem
      get :reorder
      put :update_reorder
      get :guest
    end
  end

  # Cookbook previews workers management.
  get "previews/status"
  get "previews/download"

  namespace :admin do
    resources :users do
      member do
        get :login_as
        get  "update_expiry_date/:days", to: "users#update_expiry_date", as: "update_expiry_date"
      end
    end
    get "orders/new/:cookbook_id", to: "orders#new", as: "new_order"
    resources :orders, except: :new
    resources :image_library, except: :show
  end

  # Very basic API
  namespace :api do
    post "cookbook_cost_calculator/printing"
  end

  root to: "cookbooks#index"
end