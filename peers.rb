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

get "/" do
  erb :index
end

get "/test/profile/:id" do
  user_id = params[:id]
  @user = @storage.user_by_id(user_id)

  erb :profile, layout: :footer_layout
end

# ----- SIGNUP HELPER METHODS (move somewhere else when done)

def encrypt_password(password)
  BCrypt::Password.create(password).to_s
  # BCrypt#create method returns a bunch of values for a new password (version, cost, salt...) 
  # Appending '.to_s' returns only the wanted encrypted password and not the rest of values
end

def email_in_use?(email)
  !!@storage.check_email(email)
end

def valid_email?(email)
  return false if email.size == 0
  (email.split('@').size > 1) && (email.split('.').size > 1)
end

get "/signup" do
  erb :signup_test, layout: :footer_layout
end

post "/signup" do
  email = params[:email]
  password = params[:password]
  full_name = params[:full_name]

  if email_in_use?(email)
    puts "An account with this email already exists, please login"     # Msg to console - flash implementation required
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

# ----- LOGIN HELPER METHODS (move somewhere else when done)

def valid_credentials?(id, email, password)
  credentials = retrieve_user_credentials(id)

  if credentials
    decrypted_password = BCrypt::Password.new(credentials["password"])
    credentials["email"] == email && decrypted_password == password
  else
    false
  end
end

get "/login" do
  erb :login_test, layout: :footer_layout
end

post "/login" do
  email = params[:email]
  password = params[:password]

  if valid_credentials?(email, password)
    puts "Login correctly"
    redirect "/profile"
  else
    puts "Sorry, your credentials don't exist in our database. Please try again or create an account."
    erb :login_test, layout: :footer_layout
  end
end

get "/profile" do
  # Implement details
end

get "/profile/edit" do
  erb :profile_edit_test, layout: :footer_layout
end

post "/profile/edit" do     # Shall we make this a PUT route instead (see Notions comments on routes section)
  user_id = params[:id]
  preferred_name = params[:preferred_name]
  slack_name = params[:slack_name]
  timezone = params[:timezone]
  course = params[:course]
  track = params[:track]
  about_me = params[:about_me]
  preferences = params[:preferences]

  if preferred_name.size == 0
    puts "Please enter a valid email password"
    erb :profile_edit_test, layout: :footer_layout
  elsif slack_name.size == 0
    puts "Please enter a valid email slack name"
    erb :profile_edit_test, layout: :footer_layout    
  elsif timezone.size == 0
    puts "Please enter a valid email timezone"
    erb :profile_edit_test, layout: :footer_layout
  elsif course.size == 0
    puts "Please enter a valid email password"
    erb :profile_edit_test, layout: :footer_layout
  elsif track.size == 0
    puts "Please enter a valid email password"
    erb :profile_edit_test, layout: :footer_layout
  elsif preferences.size == 0
    puts "Please enter a valid email password"
    erb :profile_edit_test, layout: :footer_layout
  else
    @storage.update_user_data(user_id, preferred_name, slack_name, timezone, course, track, about_me)
    @storage.update_user_preferences(user_id, preferences)
    erb :profile, layout: :footer_layout 
  end
end

post "/logout" do
  # TBD logout implementation
  redirect "/"  
end
