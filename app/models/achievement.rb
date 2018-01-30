class Achievement < ActiveRecord::Base
  has_many :users, :join_table => "achievement_table", :class_name => "User"
end
