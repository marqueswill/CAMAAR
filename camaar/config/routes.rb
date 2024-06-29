Rails.application.routes.draw do
  get 'home/index'

  match '/errors/forbidden', to: 'errors#forbidden', via: 'get'

  match '/errors/forbidden', to: 'errors#forbidden', via: 'get'

  scope 'users' do
    resources :forms do
      resources :answers, only: [:create]
    end
  end

  scope 'admins' do

    match '/templates', to: 'templates#index', via: 'get', as: 'templates'
    match '/templates', to: 'templates#create', via: 'post'
    match '/templates/new', to: 'templates#new', via: 'get', as: 'new_template'
    match '/templates/:id/edit', to: 'templates#edit', via: 'get', as: 'edit_template'
    match '/templates/:id', to: 'templates#show', via: 'get', as: 'template'
    match '/templates/:id', to: 'templates#update', via: 'patch'
    match '/templates/:id', to: 'templates#update', via: 'put'
    match '/templates/:id', to: 'templates#destroy', via: 'delete'



    match '/templates/:template_id/template_questions', to: 'template_questions#index', via: 'get', as: 'template_template_questions'
    match '/templates/:template_id/template_questions/new', to: 'template_questions#new', via: 'get', as: 'new_template_template_question'
    match '/templates/:template_id/template_questions/:id', to: 'template_questions#show', via: 'get', as: 'template_template_question'
    match '/templates/:template_id/template_questions/:id/edit', to: 'template_questions#edit', via: 'get', as: 'edit_template_template_question'
    match '/templates/:template_id/template_questions/:id', to: 'template_questions#destroy', via: 'delete'
    match '/templates/:template_id/template_questions', to: 'template_questions#create', via: 'post'
    match '/templates/:template_id/template_questions/:id', to: 'template_questions#update', via: 'patch'
    match '/templates/:template_id/template_questions/:id', to: 'template_questions#update', via: 'put'

    match 'results/:id', to: 'summary#summary', via: 'get', as: 'form_summary'
    match '/results', to: 'results#results', via: 'get', as: 'results'

    # resources :subject_classes, only: [:index]
    match '/classes', to: 'subject_classes#index', via: 'get'

    match '/import', to: 'admins#importdata', via: 'get', as: 'admins_import'
    match '/import', to: 'admins#import', via: 'post', as: 'admins_import_post'

    match '/dispatch', to: 'dispatch#envio', via: 'get'
    match '/dispatch', to: 'dispatch#envio', via: 'post', as: 'admins_envio_post'
  end

  devise_scope :user do
    get '/users/logout' => 'users/sessions#destroy'
    post '/users/register' => 'users/registrations#create'
    post '/users/recover-password/new' => 'users/passwords#create'
  end

  devise_scope :admin do
    get '/admins/logout' => 'admins/sessions#destroy'
    post '/admins/register' => 'admins/registrations#create'
    post '/admins/recover-password/new' => 'admins/passwords#create'
  end

  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions',
               passwords: 'users/passwords',
               confirmations: 'users/confirmations'
             },
             path: 'users',
             path_names: {

               sign_in: 'login',
               sign_up: 'register',
               sign_out: 'logout',
               password: 'recover-password',
               confirmation: 'verification'

             }

  devise_for :admins,
             controllers: {
               registrations: 'admins/registrations',
               sessions: 'admins/sessions',
               passwords: 'admins/passwords',
               confirmations: 'admins/confirmations'
             },
             path: 'admins',
             path_names: {

               sign_in: 'login',
               sign_up: 'register',
               sign_out: 'logout',
               password: 'recover-password',
               confirmation: 'verification'

             }

  get 'up' => 'rails/health#show', as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: '/mails'
  # Defines the root path route ("/")
  # root "posts#index"
  root to: 'home#index'
  default_url_options host: 'localhost', port: 3000
end
