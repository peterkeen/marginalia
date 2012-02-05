class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  after_create :create_user_email

  acts_as_tagger

  has_many :notes
  has_many :user_emails

  def create_user_email
    UserEmail.create(
      :user_id => self.id,
      :email => self.email
    )
  end

  def self.current
    @@current
  end

  def self.current=(user)
    @@current = user
  end
end
