class AchievementsUsers < ActiveRecord::Base
  validates :user_id, presence => true
  validates :achievement_id, presence => true

  belongs_to :achievement
  belongs_to :user
end
