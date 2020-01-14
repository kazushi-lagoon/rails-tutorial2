Rails.application.routes.draw do
  
  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  get 'users/new'

  root 'static_pages#home'
  # => get '/' , to: 'static_pages#home'
  # => root_path
  
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  
  # get 'static_pages/contact' の書き方（urlと、それに対応するコントローラー・アクションを一体化させた書き方）だと、
  # 名前付きルートが、static_pages_contact_path　となって長くなってしまう。
  # get  '/contact', to: 'static_pages#contact' この書き方で、名前付きルートの、contact_path　が追加される。
  
  get '/signup', to: 'users#new'
  
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  #=> resources を使わなくても、createアクションを反応させる時はpostリクエスト、という風に、restful風味にすることは可能。
  
  resources :users
  # rails routes で、一番左のPrefixのところは、最後に_pathを付けると、名前付きルートになる。
  
  resources :account_activations, only: [:edit]
  #=> get '/account_activations/:id/edit', to: 'account_activations#edit'
  # params[:id] <= 有効化トークン　:id は、別に数値でなくて、文字列でも問題ない。
  
  resources :password_resets,     only: [:new, :create, :edit, :update]

  root 'application#hello'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
