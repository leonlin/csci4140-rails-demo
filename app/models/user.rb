class User < ActiveRecord::Base
  attr_accessible :name, :password_digest, :remoeber_token
end
