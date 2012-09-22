class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :oauth2_providable, 
         :oauth2_password_grantable,
         :oauth2_refresh_token_grantable,
         :oauth2_authorization_code_grantable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :time_zone, :unique_id
  attr_accessor :newsletter_subscribe

  before_save :set_subscribed_at
  after_create :create_user_email
  after_update :update_user_email

  acts_as_tagger

  has_many :notes
  has_many :user_emails
  has_many :exports

  belongs_to :plan

  def create_user_email
    UserEmail.create(
      :user_id => self.id,
      :email => self.email
    )
  end

  def update_user_email
    if email_changed?
      e = UserEmail.find_by_email(email_was)
      e.email = email
      e.save!
    end
  end

  def self.current
    @@current
  end

  def self.current=(user)
    @@current = user
  end

  def has_guest_email?
    email.starts_with?('guest') && email.ends_with?('example.com')
  end

  def set_subscribed_at
    if self.newsletter_subscribe && !self.subscribed_at
      self.subscribed_at = Date.now.utc
    end
  end

  def stripe_fee
    (purchase_price * 0.029).round.to_i + 30
  end

  def purchase_price_minus_stripe_fee
    purchase_price - stripe_fee
  end

end
