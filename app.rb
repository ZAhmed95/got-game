require 'sinatra'
require 'sinatra/flash'
require 'json'
require 'igdb_client'
require './models'

enable :sessions

# globals
def initialize
  super

  @user = {
    name: nil,
    profile: nil,
  }

  @igdb_client = IGDB::Client.new ENV['IGDB_API_KEY']
end

# helpers
helpers do
  def logged_in
    !session[:user_id].nil?
  end

  def ensure_login
    redirect '/login' unless logged_in
  end

  def logout
    session[:user_id] = nil
    @user[:name] = nil
    @user[:profile] = nil
  end

  def error404
    status 404
    erb :error404
  end

  def redirect_here
    session[:redirect] = request.fullpath
  end

  def go_back
    redirect session[:redirect]
  end
end

get '/' do
  redirect_here
  erb :index
end

get '/signup/?' do
  erb :signup
end

post '/signup' do
  new_user = User.create(
    username: params[:username],
    password: params[:password]
  )
  profile = Profile.create(
    user_id: new_user.id,
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    birth_date: params[:birth_date]
  )
  go_back
end

post %r{/users/delete/(?<id>\d+)} do
  user_to_delete = User.find_by_id(params[:id])
  if user_to_delete and user_to_delete.id == session[:user_id] then
    user_to_delete.destroy
    logout
    go_back
  else
    # TODO: return error message explaining why user couldn't be deleted
    redirect '/'
  end
end

get '/login/?' do
  if logged_in then 
    redirect '/'
  else
    erb :login
  end
end

post '/login' do
  username = params[:username]
  password = params[:password]
  login = User.where({
    username: username, 
    password: password,
  }).first
  if login then
    # login success
    session[:user_id] = login.id
    @user[:name] = login.username
    @user[:profile] = login.profile
    go_back
  else
    flash[:message] = "Incorrect username or password"
    redirect '/login'
  end
end

get '/logout/?' do
  logout
  go_back
end

get '/users/?' do
  erb :users, locals: {users: User.includes(:posts).order(username: :asc).all}
end

# /users/:id
get %r{/users/(?<id>\d+)} do
  this_user = User.find_by_id(params[:id])
  if this_user then
    redirect_here
    erb :user, locals: {
      user: this_user, 
      profile: this_user.profile,
      posts: this_user.posts.includes(:comments).order(created_at: :desc)
    }
  else
    error404
  end
end

# posts/edit/:id
get %r{/posts/edit/(?<id>\d+)} do
  ensure_login
  id = params[:id]
  post = Post.find_by_id(id)
  if post and post.user_id == session[:user_id] then
    erb :create_post, locals: {post: post, new: false}
  else
    # either post doesn't exist, or doesn't belong to this user
    redirect '/'
  end
end

post %r{/posts/edit/(?<id>\d+)} do
  id = params[:id]
  post = Post.find_by_id(id)
  if post and post.user_id == session[:user_id] then
    post.update(
      title: params[:title],
      content: params[:content]
    )
    redirect "/posts/#{post.id}"
  else
    # TODO: give error message saying post edit failed
    redirect '/'
  end
end

# /posts/:id
get %r{/posts/(?<id>\d+)} do
  redirect_here
  id = params[:id]
  post = Post.includes(:user).find_by_id(id)
  if post then
    comments = post.comments.includes(:user)
    results = 
    if post.game_id then 
      @igdb_client.games post.game_id, fields: "name,url,cover"
    else
      []
    end
    erb :post, locals: {post: post, comments: comments, game: results[0]}
  else
    error404
  end
end

get '/posts/?' do
  redirect_here
  erb :posts, locals: {posts: Post.includes(:user, :comments).order(created_at: :desc)}
end

get '/create/?' do
  unless logged_in
    redirect '/login'
  end
  erb :create_post, locals: {post: {}, new: true}
end

post '/create' do
  user_id = session[:user_id]
  game_id = params[:game_id]
  game_title = params[:game_title]
  title = params[:title]
  content = params[:content]
  post = Post.create(
    user_id: user_id,
    game_id: game_id,
    game_title: game_title,
    title: title,
    content: content,
  )
  redirect "/posts/#{post.id}"
end

post '/comment' do
  user_id = params[:user_id]
  post_id = params[:post_id]
  body = params[:comment]
  comment = Comment.create(
    user_id: user_id,
    post_id: post_id,
    comment: body,
  )
  go_back
end

post '/search-game' do
  data = JSON.parse request.body.read
  title = data['title']
  results = @igdb_client.search_games title, :fields => "id,name,version_parent"
  # filter out the results that have a "version_parent" key,
  # these are just editions of a game
  results.reject! {|result| result.version_parent}
  erb :found_games, layout: false, locals: {games: results}
end

post '/switch-theme' do
  session[:alt_theme] = !session[:alt_theme]
  redirect back
end

get '/style.css' do
  headers 'Content-Type' => 'text/css'
  scss :style
end

get '*' do
  error404
end