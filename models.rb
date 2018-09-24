require 'sinatra/activerecord'

configure :development do
  set :database, "#{ENV['DATABASE_URL']}/gaming"
end

configure :production do
  set :database, "#{ENV['DATABASE_URL']}"
end

class User < ActiveRecord::Base
  has_one :profile, dependent: :delete
  has_many :posts, dependent: :delete_all
  has_many :comments, dependent: :delete_all
end

class Profile < ActiveRecord::Base
  belongs_to :user
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end