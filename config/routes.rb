# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

Rails.application.routes.draw do
  get 'health_check', to: 'health_check/health_check#index'

  # Error routes.
  match '/401', to: 'errors#unauthorized', via: :all, as: :unauthorized
  match '/404', to: 'errors#not_found', via: :all, as: :not_found
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_error', via: :all, as: :internal_error

  # Signin/Signup routes.
  get '/signin', to: 'users#signin', as: :signin
  get '/signup', to: 'users#new', as: :signup
  post '/signup', to: 'users#create', as: :create_user

  # Redirect to terms page
  match '/terms', to: 'users#terms', via: [:get, :post]

  # help and support
  get '/help', to: 'users#help', as: :help
  get '/support', to: 'support_email#support', as: :support

  # Admin resouces
  resources :admins, only: [:index]

  scope '/admins' do
    post '/branding', to: 'admins#branding', as: :admin_branding
    post '/coloring', to: 'admins#coloring', as: :admin_coloring
    post '/signup', to: 'admins#signup', as: :admin_signup
    get '/edit/:user_uid', to: 'admins#edit_user', as: :admin_edit_user
    post '/promote_to_admin/:user_uid', to: 'admins#promote_to_admin', as: :admin_promote
    post '/demote_from_admin/:user_uid', to: 'admins#demote_from_admin', as: :admin_demote
    post '/promote_to_moderator/:user_uid', to: 'admins#promote_to_moderator', as: :moderator_promote
    post '/demote_from_moderator/:user_uid', to: 'admins#demote_from_moderator', as: :moderator_demote
    post '/ban/:user_uid', to: 'admins#ban_user', as: :admin_ban
    post '/unban/:user_uid', to: 'admins#unban_user', as: :admin_unban
  end

  scope '/themes' do
    get '/primary', to: 'themes#index', as: :themes_primary
  end

  #support email
  post '/support_email', to: 'support_email#create', as: :support_email
  #resources :support_email, only: [:create]


  # Password reset resources.
  resources :password_resets, only: [:new, :create, :edit, :update]

  # Account activation resources
  scope '/account_activations' do
    get '/', to: 'account_activations#show', as: :account_activation
    get '/edit', to: 'account_activations#edit', as: :edit_account_activation
    post '/resend', to: 'account_activations#resend', as: :resend_email
  end

  # User resources.
  scope '/u' do
    # Handles login of greenlight provider accounts.
    post '/login', to: 'sessions#create', as: :create_session

    # Log the user out of the session.
    get '/logout', to: 'sessions#destroy'

    # Account management.
    get '/:user_uid/edit', to: 'users#edit', as: :edit_user
    patch '/:user_uid/edit', to: 'users#update', as: :update_user
    delete '/:user_uid', to: 'users#destroy', as: :delete_user

    # All user recordings
    get '/:user_uid/recordings', to: 'users#recordings', as: :get_user_recordings
  end

  # Handles Omniauth authentication.
  match '/auth/:provider/callback', to: 'sessions#omniauth', via: [:get, :post], as: :omniauth_session
  get '/auth/failure', to: 'sessions#omniauth_fail'

  # Room resources.
  resources :rooms, only: [:create, :show, :destroy], param: :room_uid, path: '/'

  # Extended room routes.
  scope '/:room_uid' do
    post '/', to: 'rooms#join'
    patch '/', to: 'rooms#update', as: :update_room
    post '/update_settings', to: 'rooms#update_settings'
    post '/start', to: 'rooms#start', as: :start_room
    get '/logout', to: 'rooms#logout', as: :logout_room
  end

  # Recording operations routes
  scope '/:meetingID' do
    # Manage recordings
    scope '/:record_id' do
      post '/', to: 'recordings#update_recording', as: :update_recording
      delete '/', to: 'recordings#delete_recording', as: :delete_recording
    end
  end

  root to: 'main#index'
end
