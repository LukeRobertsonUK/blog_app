require 'sinatra'
require 'sinatra/contrib/all'
require 'pry'
require 'pg'
require 'haml'

username = 'luke'
password = 'insane'

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

  if params[:tag]
    sql = "SELECT * FROM blogs WHERE tags LIKE '%#{params[:tag]}%' ORDER BY post_time DESC"
  else
    sql = "SELECT * FROM blogs ORDER BY post_time DESC"
  end
  @recent_posts = @db.exec(sql)
  haml :list
end


# display a post in detail
get '/display/:id' do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog = @db.exec(sql).first
  sql_comments = "SELECT * FROM comments WHERE blog_id =#{params[:id].to_i} ORDER BY post_time DESC"
  @comments = @db.exec(sql_comments)
  haml :display
end

# admin functions

get "/admin" do
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
  if params["username"].to_s == username && params["password"].to_s == password
      session[:admin] = true
      redirect "/admin"
    else
      redirect "/verification"
    end
end



post "/delete_verification/:id" do
 if params["password"].to_s == password
  sql = "DELETE FROM blogs WHERE id= '#{params[:id]}'"
  sql_comments = "DELETE FROM comments WHERE blog_id='#{params[:id]}'"
  @db.exec(sql_comments)
  @db.exec(sql)
  redirect to '/admin'
else
  target = "/delete_verification/#{params[:id]}"
  redirect to target
end
end

get "/delete_verification/:id" do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog_to_delete = @db.exec(sql).first
  haml :delete_verification
end



get "/delete/:id" do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog_to_delete = @db.exec(sql).first
  haml :delete_verification
end


get "/create" do
   haml :create
end

post "/new" do
  @title = params[:title].to_s
  @author = params[:author].to_s
  @tags = params[:tags].to_s
  @content = params[:content].to_s
  sql = "INSERT INTO blogs (title, post_time, author, tags, content) VALUES ('#{@title}', CURRENT_TIMESTAMP, '#{@author}', '#{@tags}', '#{@content}')"
  @db.exec(sql)
  redirect to '/admin'
end

get "/update/:id" do
  sql = "SELECT * FROM blogs WHERE id = '#{params[:id]}'"
  @blog = @db.exec(sql).first
  sql_comments = "SELECT * FROM comments WHERE blog_id =#{params[:id].to_i} ORDER BY post_time DESC"
  @comments = @db.exec(sql_comments)
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


post "/comment" do

  @author = params[:author].to_s
  @content = params[:content].to_s
  @blog_id = params[:blog_id]
  sql = "INSERT INTO comments (post_time, author, content, blog_id) VALUES (CURRENT_TIMESTAMP, '#{@author}', '#{@content}', #{@blog_id})"
  @db.exec(sql)
  redirect to "/display/#{params[:blog_id]}"
end

get "/delete_comment/:id" do
  sql = "SELECT * FROM comments WHERE id = '#{params[:id]}'"
  @comment_to_delete = @db.exec(sql).first
  haml :delete_comment_verification
end

get "/delete_comment_verification/:id" do
  sql = "SELECT * FROM comments WHERE id = '#{params[:id]}'"
  @comment_to_delete = @db.exec(sql).first
  haml :delete_comment_verification
end


post "/delete_comment_verification/:id" do
 if params["password"].to_s == password
  sql = "DELETE FROM comments WHERE id= #{params[:id]}"
  sql_blog = "SELECT * FROM comments WHERE id= #{params[:id]}"
  @comment = @db.exec(sql_blog).first
  @db.exec(sql)
  redirect to "/update/#{@comment["blog_id"].to_i}"
else
  target = "/delete_comment_verification/#{params[:id]}"
  redirect to target
end
end



