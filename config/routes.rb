Annotest::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", registrations: 'registrations' }

  get "welcome/index"

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
  #       get 'recent', :on => :collection
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

  root :to => 'welcome#index'
  resources :annotation
  delete '/annotation/:id', to: 'annotation#delete', :constraints => { :id => /.*/ }
  put '/annotation/:id', to: 'annotation#update', :constraints => { :id => /.*/ }

  resources :annotation_lists, path: 'list'
  get '/list/:id', to: 'annotation_lists#show', :constraints => { :id => /.*/ }
  get '/lists', to: 'annotation_lists#index'

  get '/canvas/:id', to: 'canvas#show'

  resources :projects
  resources :annotation_layers, path: 'layers', defaults: {format: :json}
  resources :annotation_layers, path: 'layer', defaults: {format: :json}
  resources :manifests, path: 'manifest',  defaults: {format: :json}


  get '/viewer.html' => redirect('http://vm-odaiprd-01.its.yale.edu/manuscripts/')


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via index requests.
  # match ':controller(/:action(/:id))(.:format)'
end
