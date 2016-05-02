require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret_password"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if !session[:user_id]
      erb :'users/create_user'
    else 
      redirect '/tweets'
    end
  end

  get '/users/:slug' do 
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  post '/signup' do
    if params[:username].empty? || params[:email].empty? || params[:password].empty?
      redirect '/signup'
    else
      user = User.create(username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = user.id
      redirect '/tweets'
    end
  end

  get '/login' do 
    if !session[:user_id]
      erb :'users/login'
    else
      redirect '/tweets'
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/tweets'
    else
      redirect '/signup'
    end
  end

  get '/tweets' do 
    if !session[:user_id]
      redirect '/login'
    else
      @tweets = Tweet.all 
      erb :'tweets/tweets'
    end
  end

  get '/tweets/new' do 
    if !session[:user_id] 
      redirect '/login'
    else
      erb :'tweets/create_tweet'
    end
  end

  post '/tweets' do
    if params[:content] == "" || params[:content] == " "
      redirect to "/tweets/new"
    else
      user = User.find_by_id(session[:user_id])
      @tweet = Tweet.create(content: params[:content], user_id: user.id)
      redirect to "/tweets/#{@tweet.id}"
    end
  end

  get '/tweets/:id' do
    if is_logged_in?
      @tweet = Tweet.find(params[:id]) 
      erb :'tweets/show_tweet'
    else
      redirect '/login'
    end
  end

  get '/tweets/:id/edit' do
    if !session[:user_id]
      redirect to '/login'
    else
      @tweet = Tweet.find_by_id(params[:id])
      if @tweet.user_id == session[:user_id]
        erb :'tweets/edit_tweet'
      else
        redirect to '/tweets'
      end
    end
  end

  patch '/tweets/:id' do
    if params[:content] == ""
      redirect to "/tweets/#{params[:id]}/edit"
    else
      @tweet = Tweet.find_by_id(params[:id])
      @tweet.content = params[:content]
      @tweet.save
      redirect to "/tweets/#{@tweet.id}"
    end
  end

  delete '/tweets/:id/delete' do
    @tweet = Tweet.find_by_id(params[:id])
    if !session[:user_id]
      redirect to '/login'
    else
      if @tweet.user_id == session[:user_id]
        @tweet.delete
        redirect to '/tweets'
      else
        redirect to '/tweets'
      end
    end
  end

  get '/logout' do 
    if is_logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
    end
  end

  helpers do 
    def is_logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end