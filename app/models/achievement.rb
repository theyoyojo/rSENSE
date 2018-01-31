class Achievement < ActiveRecord::Base
  has_many :achievements_users, class_name: AchievementsUsers
  has_many :users, :through => :achievements_users
end
