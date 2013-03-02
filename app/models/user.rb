class User < ActiveRecord::Base
  attr_accessible :name, :remember_token, :password, :password_confirmation
  before_save :create_remember_token
  has_secure_password
  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
