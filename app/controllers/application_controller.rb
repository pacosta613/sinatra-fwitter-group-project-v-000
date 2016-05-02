require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if !is_logged_in? 
      erb :'users/create_user'
    else 
      redirect '/tweets'
    end
  end

  post '/signup' do
    user = User.new(username: params[:username], email: params[:email], password: params[:password])
    if params[:username].empty? || params[:email].empty? || params[:password].empty?
      redirect '/signup'
    else
      user.save
      session[:user_id] = user.id
      redirect '/tweets'
    end
  end

  get '/login' do 
    if !is_logged_in?
      erb :'users/login'
    else
      redirect '/tweets'
    end
  end

  post '/login' do
    if params[:username].empty? || params[:password].empty?
      redirect '/login'
    else
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect '/tweets'
      else
        redirect '/'
      end
    end
  end

  get '/tweets' do 
    if is_logged_in?
      @tweets = Tweet.all 
      erb :'tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/tweets/new' do 
    if is_logged_in?  
      erb :'tweets/create_tweet'
    else
      redirect '/login'
    end
  end

  post '/tweets' do 
    @tweet = Tweet.new(params[:tweet])
    @tweet.user_id = session[:user_id]

    if @tweet[:content] != ''
      @tweet.save
    else
      redirect '/tweets/new'
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

  get '/users/:slug' do 
    @user = User.find(params[:slug])
    erb :'users/show'
  end

  get '/tweets/:id/edit' do
    if is_logged_in?
      @tweet = Tweet.find(params[:id])
      if @tweet.user_id == session[:user_id]
        erb :'tweets/edit_tweet'
      else
        redirect '/tweets/#{@tweet.id}'
      end
    else
      redirect '/login'
    end
  end

  patch '/tweets/:id' do 
    @tweet = Tweet.find(params[:id])
    if params[:content].empty?
      redirect '/tweets/#{@tweet.id}/edit'
    else
      @tweet.update(content: params[:content])
      redirect '/tweets/#{@tweet.id}'
    end
  end

  delete '/tweets/:id/delete' do
    if is_logged_in?
      @tweet = Tweet.find(params[:id])
      if @tweet.user_id == session[:user_id]
        @tweet.delete 
        redirect '/tweets'
      else
        redirect '/tweets/#{@tweet.id}'
      end
    else
      redirect '/login'
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