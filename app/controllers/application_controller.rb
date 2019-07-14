class ApplicationController < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  configure do
  	set :views, "app/views"
    set :public_dir, "public"
    #enables sessions as per Sinatra's docs. Session_secret is meant to encript the session id so that users cannot create a fake session_id to hack into your site without logging in. 
    enable :sessions
    set :session_secret, "secret"
  end

  # Renders the home or index page
  get '/' do
    @urls = Url.all
    @urls_count = Url.count
    erb :home, layout: :template
  end

  post '/' do
    if params["ori_url"] == nil
      redirect '/'
    else
        @urls = Url.all
        @urls_count = Url.count
        all_ori_url=Url.pluck(:ori_url)
        if all_ori_url.include? (params["ori_url"])
            @return_url = Url.find_by(ori_url: params["ori_url"])
        else
              session[:user_id] != nil ? @user = User.find(session[:user_id]) : @user = User.find_by(name: "Guest")
              base58 =["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
              new_s_url = base58.sample(4)
              all_short_url=Url.all.pluck(:short_url)
              @new_url = Url.create(user_id: @user.id, user_name:@user.name)
              if !all_short_url.include? (params["short_url"])
                  @new_url.short_url = new_s_url.join
              else 
                  loop do
                    new_s_url = base58.sample(4)
                    break if !all_short_url.include? (new_s_url.join)
                  end
                  @new_url.short_url = new_s_url.join
              end
              @new_url.ori_url = params["ori_url"]
              @new_url.track = 0
              @new_url.save
            end
            erb :home, layout: :template
        end
        
  end

   # Renders the user's individual home/account page. 
   get '/users/home' do
    if session[:user_id] != nil
      @user = User.find(session[:user_id])
      @urls = Url.all
      @urls_count = Url.count
      erb :home, layout: :template
    else
      redirect "/sessions/login"
    end
  end

  get '/users/my_urls' do
    @user = User.find(session[:user_id])
    @my_urls = Url.where(user_id: @user.id)
    # byebug
    erb :'/users/my_urls', layout: :template
  end

  get '/:short_url' do
    add_track = Url.all.find_by(short_url: params[:short_url])
    add_track.track += 1
    add_track.save
    redirect "#{add_track.ori_url}"
  end

  
  # Renders the sign up/registration page in app/views/registrations/signup.erb
  get '/registrations/signup' do
    erb :'/registrations/signup', layout: :template
  end

  # Handles the POST request when user submits the Sign Up form. Get user info from the params hash, creates a new user, signs them in, redirects them. 
  post '/registrations' do
   user = User.create(name: params["name"], email: params["email"])
   user.password = params["password"]
   user.save
   session[:user_id]=user.id
   redirect 'users/home'
  end
  
  # Renders the view page in app/views/sessions/login.erb
  get '/sessions/login' do
   erb :'sessions/login', layout: :template
  end

  # Handles the POST request when user submites the Log In form. Similar to above, but without the new user creation.
  post '/sessions' do
    user = User.find_by(email: params["email"])
    if user.password == params["password"]
      session[:user_id] = user.id
      redirect '/users/home'
    else 
      redirect '/sessions/login'
    end
  end

  # Logs the user out by clearing the sessions hash. 
  get '/sessions/logout' do
    session.clear
    redirect '/'
  end

 

end
