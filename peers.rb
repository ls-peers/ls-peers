require "sinatra"
require "tilt/erubis"

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

get "/users" do
  @user = @storage.first_user()
  return "#{@user["firstname"]} (id: #{@user["pkey"]}) is a user"
end
