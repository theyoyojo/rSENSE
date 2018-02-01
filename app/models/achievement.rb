class Achievement < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true
  validates :points, presence: true 
  validates :description, presence: true 

  has_many :achievements_users, class_name: AchievementsUser
  has_many :users, :through => :achievements_users


end
