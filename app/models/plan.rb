class Plan < ActiveRecord::Base
  has_many :users

  after_create :create_stripe_plan
  validates :slug, :uniqueness => true

  def create_stripe_plan
    Stripe::Plan.create(
      :id       => self.slug,
      :name     => self.name,
      :amount   => self.amount,
      :interval => self.interval,
      :currency => 'usd'
    )
  end

  def stripe_plan
    Stripe::Plan.retrieve(self.slug)
  end
  
end
