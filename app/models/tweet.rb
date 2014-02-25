class Tweet < ActiveRecord::Base
  #attr_accessible :content, :user_id  
  #attr_accessible :content
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 139 }

  default_scope order: 'tweets.created_at DESC'
end
