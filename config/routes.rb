Ideas::Application.routes.draw do
  devise_for :users

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

  match '/register' => 'registration#new', :via => :get
  match '/register' => 'registration#create', :via => :post
  match '/billing'  => 'registration#new_billing', :via => :get
  match '/billing'  => 'registration#charge_customer', :via => :post

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

  scope '/admin' do
    constraints lambda { |request| request.env['warden'].user && request.env['warden'].user.is_admin } do
      mount DelayedJobWeb, :at => 'jobs'
      match 'abingo(/:action(/:id))', :to => 'abingo', :as => :bingo
    end
  end

  # match "/admin/jobs" => DelayedJobWeb, :anchor => false
  # match '/admin/vanity(/:action(/:id(.:format)))', :controller=>:vanity

  match '/:slug' => 'marketing#landing_page'
end
