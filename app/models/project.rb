class Project < ActiveRecord::Base
  belongs_to :user
  has_many :notes, :order => "position"
end
