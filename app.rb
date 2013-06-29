require 'sinatra'
require 'sinatra/contrib/all'
require 'pry'
require 'pg'
require 'haml'

before do
  @db ||= PG.connect(dbname: "blog_app")
end

after do
  @db.close
end

configure do
# server configuration
  enable :sessions
# allows cookies
  set :environment, "development"
end


get '/' do
  sql = "SELECT * FROM blogs ORDER BY post_time DESC limit 5"
  @recent_posts = @db.exec(sql)
  haml :index
end

#List Posts
get '/list' do
  sql = "SELECT * FROM blogs ORDER BY post_time DESC"
  @recent_posts = @db.exec(sql)
  haml :list
end


# display a post in detail
get '/display/:id' do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog = @db.exec(sql).first
  haml :display
end

# admin functions



get "/admin" do
  binding.pry
  unless session[:admin] == true
    redirect "/verification"
  end
  sql = "SELECT * FROM blogs ORDER BY post_time DESC"
  @recent_posts = @db.exec(sql)
  haml :admin
end

get "/verification" do
  haml :verification
end

post "/verification" do
  binding.pry
  if params["login"].to_s == "robertsonlz" && params["password"].to_s == "insane"
      session[:admin] = true
      redirect "/admin"
    else
      redirect "/verification"
    end
end

get "/delete/:id" do
  sql = "DELETE FROM blogs WHERE id= '#{params[:id]}'"
  @db.exec(sql)
  redirect to '/admin'
end

get "/create" do
   haml :create
end

post "/new" do
  @title = params[:title].to_s
  @author = params[:author].to_s
  @tags = params[:tags].to_s
  @content = params[:content].to_s
  sql = "INSERT INTO blogs (title, author, tags, content) VALUES ('#{@title}', '#{@author}', '#{@tags}', '#{@content}')"
  @db.exec(sql)
  redirect to '/'
end

get "/update/:id" do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog = @db.exec(sql).first
  haml :update
end

post "/update/:id" do
  @title = params[:title].to_s
  @author = params[:author].to_s
  @tags = params[:tags].to_s
  @content = params[:content].to_s
  @id = params[:blog_id]
  sql = "UPDATE blogs SET title= '#{@title}', author='#{@author}', tags='#{@tags}', content='#{@content}' WHERE id = '#{params[:id]}'"
  @db.exec(sql)
  redirect to '/admin'
end


