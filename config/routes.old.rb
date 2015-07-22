CookbookHeritage::Application.routes.draw do
  
  get "account/login"
  post "account/login"
  get "account/logout"
  get "account/forgot_password"
  post "account/forgot_password"
  get "account/signup"
  post "account/signup"
  get "account/account_created"
  post "account/account_created"
  get "account/upgrade"
  get "account/change_login"
  post "account/change_login"
  get "account/express"
  post "account/express"
  post "account/thankyou"
  get "account/thankyou"
  resources :account do
    member do
      post :edit
    end
  end

  post "cookbook/edit_title"
  put "cookbook/edit_title"
  get "cookbook/faq"
  get "cookbook/intro"
  post "cookbook/intro"
  get "cookbook/create"
  get "cookbook/design"
  post "cookbook/design"
  match "cookbook/design/:id" => "cookbook#design"
  get "cookbook/design_set"
  # get "cookbook/edit_title"
  get "cookbook/intro"
  get "cookbook/contributors"
  get "cookbook/recipes"
  get "cookbook/preview"
  get "cookbook/select_cookbook"
  get "cookbook/layout"
  get "cookbook/welcome"
  resources :cookbook do
    member do
      get :preview
    end
  end

  get "order/index"
  put "order/index"
  post "order/index"
  get "order/update"
  get "order/post"
  get "order/customer_details"
  get "order/reorder"
  get "order/thankyou"
  get "order/printer_quote"
  get "order/confirmation"
  post "order/customer_details"
  get "order/cancel"
  resources :order

  get "pdf/preview_index"
  get "pdf/preview_cover"
  get "pdf/preview_inner_cover"
  get "pdf/preview_introduction"
  get "pdf/preview_table_of_contents"
  get "pdf/preview_section"
  get "pdf/preview_recipe"
  get "pdf/preview_extra_page"
  get "pdf/preview"
  get "pdf/preview_status"
  resources :pdf

  resources :contributor do
    member do
      get "resend_invite"
    end
  end

  resources :recipe do
    member do
      get :preview
    end
  end

  get "section/set_order"
  resources :section

  resources :extra_page do
    member do
      get :preview
    end
  end

  namespace :admin do

    resources :library_images do
      collection do
        get :load_image_library
        post :load_image_library
      end
    end

  end

  get "public_calculator/index"

  root to: "cookbook#index"

end
