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
      session[:id] = user.id
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
        session[:id] = user.id
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
      redirect '/tweets'
    end
  end

  get '/tweets/new' do 
    erb :create_tweet
  end

  post '/tweets' do 
    redirect '/tweets'
  end

  get '/tweets' do 
    erb :show_tweet
  end

  get '/tweets/:id/edit' do
    erb :edit_tweet
  end

  post '/tweets/:id' do 
    redirect '/tweets'
  end

  delete '/tweets/:id/delete' do 
    #redirect '/tweets/'
  end

  helpers do 
    def is_logged_in?
      !!session[:id]
    end

    def current_user
      User.find(session[:id])
    end
  end
end