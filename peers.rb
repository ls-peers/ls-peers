require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"
require 'digest/md5'

require_relative "database_persistence"

enable :sessions

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

after do
  @storage.disconnect
end

before do
  @storage = DatabasePersistence.new()
end

# ----- SIGNUP HELPER METHODS

def encrypt_password(password)
  # '.to_s' to return only the encrypted password (not version, cost, salt etc.)
  BCrypt::Password.create(password).to_s
end

def email_in_use?(email)
  !!@storage.get_user_by_email(email)
end

def valid_email?(email)
  return false if email.size == 0
  (email.split('@').size > 1) && (email.split('.').size > 1)
end

# ----- LOGIN HELPER METHODS

def valid_credentials?(email, password)
  @user = @storage.get_user_by_email(email)

  if @user && @user.password
    decrypted_password = BCrypt::Password.new(@user.password)
    decrypted_password == password
  else
    false
  end
end

# ----- ROUTES

get "/" do
  erb :index
end

get "/about" do
  erb :about, layout: :footer_layout
end

get "/signup" do
  erb :signup, layout: :footer_layout
end

post "/signup" do
  email = params[:email]
  password = params[:password]
  full_name = params[:full_name]

  if email_in_use?(email)
    session[:error] = "An account with this email already exists"
    redirect "/signup"
  elsif !valid_email?(email)
    session[:error] = "Please enter a valid email address"
    redirect "/signup"
  elsif password.size == 0
    session[:error] = "Please enter a valid email password"
    redirect "/signup"
  elsif full_name.size == 0
    session[:error] = "Please enter a valid full name"
    redirect "/signup"
  else
    password = encrypt_password(password)
    @storage.add_new_user(email, password, full_name)
    session[:success] = "Your account has been created. Please login using your credentials"
    redirect "/login"
  end
end

get "/login" do
  erb :login, layout: :footer_layout
end

post "/login" do
  email = params[:email]
  password = params[:password]

  if valid_credentials?(email, password)
    @user = @storage.get_user_by_email(email)
    session[:user_id] = @user.id # session can be introspected elsewhere for auth
    redirect "/profile"
  else
    session[:error] = "Wrong username or password."
    redirect "/login"
  end
end

get "/logout" do
  session.clear
  redirect "/"
end

get "/profile" do
  if session[:user_id]
    @user = @storage.get_user_with_preferences_by_id(session[:user_id])

    if @user.is_complete?
      erb :profile, layout: :footer_layout
    else
      redirect "/profile/edit"
    end
  else
    session[:error] = "Sorry, you must be login to view this content"
    erb :login, layout: :footer_layout
  end
end

get "/profile/edit" do
  if session[:user_id]
    @user = @storage.get_user_with_preferences_by_id(session[:user_id])
    @tracks = @storage.get_tracks()
    @courses = @storage.get_courses()
    @timezones = @storage.get_timezones()
    @preferences = @storage.get_preferences()

    erb :profile_edit, layout: :footer_layout
  else
    session[:error] = "Sorry, you must be login to view this content"
    erb :login, layout: :footer_layout
  end
end

post "/profile/edit" do
  if session[:user_id]
    @user = @storage.get_user_by_id(session[:user_id])
    @tracks = @storage.get_tracks()
    @courses = @storage.get_courses()
    @timezones = @storage.get_timezones()
    @preferences = @storage.get_preferences()

    user_id = @user.id
    preferred_name = params[:preferred_name]
    slack_name = params[:slack_name]
    track = params[:track]
    course = params[:course]
    timezone = params[:timezone]
    preferences = params[:preferences]
    about_me = params[:about_me]

    if preferred_name.size == 0
      session[:error] = "Please enter a valid preferred name"
      erb :profile_edit, layout: :footer_layout
    elsif slack_name.size == 0
      session[:error] = "Please enter a valid slack name"
      erb :profile_edit, layout: :footer_layout
    elsif track.size == 0
      session[:error] = "Please enter a valid track"
      erb :profile_edit, layout: :footer_layout
    elsif course.size == 0
      session[:error] = "Please enter a valid course"
      erb :profile_edit, layout: :footer_layout
    elsif timezone.size == 0
      session[:error] = "Please enter a valid timezone"
      erb :profile_edit, layout: :footer_layout
    elsif !preferences || preferences.size == 0
      session[:error] = "Please select at least one preference"
      erb :profile_edit, layout: :footer_layout
    else
      @storage.update_user_data(user_id, preferred_name, slack_name, track, course, timezone, about_me)
      @storage.delete_user_preferences(user_id)
      @storage.update_user_preferences(user_id, preferences)
      redirect "/profile"
    end
  else
    puts "Sorry, you must be login to view this content"
    erb :login, layout: :footer_layout
  end
end

get "/search" do
  if session[:user_id]
    tracks = params[:tracks]
    courses = params[:courses]
    timezones = params[:timezones]
    preferences = params[:preferences]
    @user_results = @storage.get_users(tracks, courses, timezones, preferences)

    @tracks = @storage.get_tracks()
    @courses = @storage.get_courses()
    @timezones = @storage.get_timezones()
    @preferences = @storage.get_preferences()
    erb :search, layout: :footer_layout
  else
    session[:error] = "Sorry, you must be login to view this content"
    erb :login, layout: :footer_layout
  end
end

get "/profile/:id" do
  if session[:user_id]
    @user = @storage.get_user_with_preferences_by_id(params[:id])
    erb :other_user_profile, layout: :footer_layout
  else
    session[:error] = "Sorry, you must be login to view this content"
    erb :login, layout: :footer_layout
  end
end
