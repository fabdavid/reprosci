Rails.application.routes.draw do
  resources :comment_checks
  resources :abuse_reports
  resources :abuse_report_types
  resources :workspace_orcid_users
  resources :banned_orcid_users
  resources :orcid_users
  resources :tags
  resources :assessments
  resources :assessment_types
  resources :assertion_versions
  resources :workspaces, param: :key do
    member do
      post :accept_disclaimer
      get :display_disclaimer
      get :get_author_list
      get :get_stats
      get :get_file
      get :subscribe
      get :latest_changes
    end
    collection do
      get :search
      post :do_search
      post :set_search_session
    end
  end
  resources :shares do 
    member do
      post :ban
      post :unban
    end
  end
  resources :rels
  resources :rel_types
  resources :techniques
  resources :assertion_types
  resources :assertions do 
    collection do
      get :search
      post :do_search
      post :set_search_session
    end
    member do
      get :get_details
      get :get_history
    end
  end
  resources :organisms
  resources :ensembl_subdomains
  resources :claim_types
  resources :claims
  resources :genes do
    collection do
      get :search
      get :autocomplete
    end
  end
  devise_for :users #, skip: [:sessions, :registrations]
#  as :user do
#    get 'signin', to: 'devise/sessions#new', as: :new_user_session
#    post 'signin', to: 'devise/sessions#create', as: :user_session
#    delete 'signout', to: 'devise/sessions#destroy', as: :destroy_user_session
#    get 'signup', to: 'devise/registrations#new', as: :new_user_registration
#  end
  resources :articles, param: :key do
    collection do
      get :search
      post :do_search
      post :set_search_session
    end
    member do
      get :get_assertion_type
      post :set_assertion_order
      post :validate
    end
  end
  resource :home do
    collection do
      get :faq
      get :welcome
      get :associate_orcid
    end
  end
  
  resources :journals
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

   match 'faq' => 'home#faq', :via => [:get]
  match 'welcome' => 'home#welcome', :via => [:get]
 match '/associate_orcid' => 'home#associate_orcid', :via => [:get]

# root to: 'workspace#index'
# root to: 'workspaces#show', :key => "3tebs5"
 root to: 'home#welcome' 
end

