require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"

require_relative "database_persistence"

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
  BCrypt::Password.create(password).to_s
  # BCrypt#create method returns a bunch of values for a new password (version, cost, salt...)
  # Appending '.to_s' returns only the wanted encrypted password and not the rest of values
end

def email_in_use?(email)
  !!@storage.get_id_by_email(email)
end

def valid_email?(email)
  return false if email.size == 0
  (email.split('@').size > 1) && (email.split('.').size > 1)
end

# ----- LOGIN HELPER METHODS

def valid_credentials?(email, password)
  @password = @storage.get_password_by_email(email)

  if @password
    decrypted_password = BCrypt::Password.new(@password)
    decrypted_password == password
  else
    false
  end
end

def is_user_login?(id, email)
  id == @storage.get_id_by_email(email)
end

# ----- ROUTES

get "/" do
  erb :index
end

# Test route, delete when done with profile route
get "/test/profile/:id" do
  user_id = params[:id]
  @user = @storage.get_user_by_id(user_id)

  erb :profile, layout: :footer_layout
end

get "/signup" do
  erb :signup_test, layout: :footer_layout
end

post "/signup" do
  email = params[:email]
  password = params[:password]
  full_name = params[:full_name]

  if email_in_use?(email)
    puts "An account with this email already exists, please login"     # Temp. msg to console -> flash msg to be implemented
    erb :signup_test, layout: :footer_layout
  elsif !valid_email?(email)
    puts "Please enter a valid email address"
    erb :signup_test, layout: :footer_layout
  elsif password.size == 0
    puts "Please enter a valid email password"
    erb :signup_test, layout: :footer_layout
  elsif full_name.size == 0
    puts "Please enter a valid full name"
    erb :signup_test, layout: :footer_layout
  else
    password = encrypt_password(password)
    @storage.add_new_user(email, password, full_name)
    puts "Your account has been created. Please login using your credentials"
    redirect "/login"
  end
end

get "/login" do
  erb :login_test, layout: :footer_layout
end

post "/login" do
  email = params[:email]
  password = params[:password]

  if valid_credentials?(email, password)
    @user = @storage.get_user_by_email(email)
    puts "Login completed"
    redirect "/profile/#{@user.id}"
  else
    puts "Sorry, your credentials don't exist in our database. Please try again or create an account."
    erb :login_test, layout: :footer_layout
  end
end

get "/logout" do         # To be implemented
  # So far it just redirects to "/". I tried with '@storage.disconnet' but raises an error
  puts "Logout complete"
  redirect "/"
end

get "/profile/:id" do
  user_id = params[:id]
  @user = @storage.get_user_by_id(user_id)
  if is_user_login?(@user.id, @user.email)               # implemented as:  id == @storage.get_id_by_email(email)
    erb :profile, layout: :footer_layout
  else
    puts "Sorry, you must be login to view this content"
    erb :login_test, layout: :footer_layout
  end
end

get "/profile/:id/edit" do
  user_id = params[:id]
  @user = @storage.get_user_by_id(user_id)
  erb :profile_edit_test, layout: :footer_layout
end

post "/profile/:id/edit" do                # Shall we make this a PUT route instead (see Notions comments on routes section)
  user_id = params[:id]
  preferred_name = params[:preferred_name]
  slack_name = params[:slack_name]
  track = params[:track]
  course = params[:course]
  timezone = params[:timezone]
  preferences = params[:preferences]
  about_me = params[:about_me]

  if preferred_name.size == 0
    puts "Please enter a valid preferred name"
    erb :profile_edit_test, layout: :footer_layout
  elsif slack_name.size == 0
    puts "Please enter a valid slack name"
    erb :profile_edit_test, layout: :footer_layout
  elsif track.size == 0
    puts "Please enter a valid track"
    erb :profile_edit_test, layout: :footer_layout
  elsif course.size == 0
    puts "Please enter a valid course"
    erb :profile_edit_test, layout: :footer_layout
  elsif timezone.size == 0
    puts "Please enter a valid timezone"
    erb :profile_edit_test, layout: :footer_layout
  elsif preferences.size == 0
    puts "Please enter a valid preference"
    erb :profile_edit_test, layout: :footer_layout
  else
    @storage.update_user_data(user_id, preferred_name, slack_name, track, course, timezone, about_me)
    @storage.update_user_preferences(user_id, preferences)
    @user = @storage.get_user_by_id(user_id)
    erb :profile, layout: :footer_layout
  end
end
