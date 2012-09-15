Ideas::Application.routes.draw do

  resources :clients

  match '/users/sign_up' => redirect('/')

  devise_for :users

  constraints DomainConstraint.new('storywritingonline.com') do
    root :to => 'marketing#landing_page', :slug => 'story-writing-online'
  end

  constraints DomainConstraint.new(['storywritingonline.net', 'storywritingonline.org']) do
    root :to => redirect('http://www.storywritingonline.com')
  end

  constraints DomainConstraint.new('novelwritingonline.com') do
    root :to => 'marketing#landing_page', :slug => 'novel-writing-online'
  end

  constraints DomainConstraint.new(['novelwritingonline.net', 'novelwritingonline.org']) do
    root :to => redirect('http://www.novelwritingonline.com')
  end

  constraints DomainConstraint.new('nanowrimoapp.com') do
    root :to => 'marketing#landing_page', :slug => 'nanowrimo-app'
  end

  constraints DomainConstraint.new(['nanowrimoapp.net', 'nanowrimoapp.org']) do
    root :to => redirect('http://www.nanowrimoapp.com')
  end

  constraints DomainConstraint.new('onlinewritingapplication.com') do
    root :to => 'marketing#landing_page', :slug => 'online-writing-application'
  end

  constraints DomainConstraint.new(['onlinewritingapplication.net', 'onlinewritingapplication.org']) do
    root :to => redirect('http://www.onlinewritingapplication.com')
  end

  match 'notes/mgcreate' => 'notes#create_from_mailgun'
  match 'notes/search'   => 'notes#search'
  match 'notes/reply'    => 'notes#update_from_mailgun'
  match 'notes/:id/append' => 'notes#append', :via => [:put, :post]
  match 'notes/:id/append' => 'notes#append_view', :via => :get
  match 'notes/:id/share' => 'notes#share_by_email', :via => :post
  match 'notes/:id/share' => 'notes#share', :via => :get
  match '/notes/:share_id/view' => 'notes#share_view', :via => :get
  match '/notes/:id/unshare' => 'notes#unshare', :via => :get
  match "/export" => "notes#export", :via => :get

  match '/notes/:id/versions' => 'notes#versions', :via => :get
  match '/notes/:id/versions/:version_id' => 'notes#show_version', :via => :get

  match '/register' => 'registration#new', :via => :get, :as => :new
  match '/register' => 'registration#create', :via => :post, :as => :create
  match '/billing'  => 'registration#new_billing', :via => :get, :as => :new_billing
  match '/billing'  => 'registration#charge_customer', :via => :post, :as => :charge_customer

  resources :notes
  resources :tags
  resources :addresses

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'marketing#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  match '__stripe', :to => 'stripe_export#index', :as => :index

  scope '/admin' do
    constraints lambda { |request| request.env['warden'].user && request.env['warden'].user.is_admin } do
      mount DelayedJobWeb, :at => 'jobs'
      match 'abingo(/:action(/:id))', :to => 'abingo', :as => :bingo
    end
  end

  # match "/admin/jobs" => DelayedJobWeb, :anchor => false
  # match '/admin/vanity(/:action(/:id(.:format)))', :controller=>:vanity

  mount Devise::Oauth2Providable::Engine => '/oauth'

  match '/:slug' => 'marketing#landing_page'
end
