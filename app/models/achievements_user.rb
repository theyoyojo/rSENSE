class AchievementsUser < ActiveRecord::Base
  validates :achievement_id, presence: true
  validate :validate_achievement_id

  validates :user_id, presence: true 
  validate :validate_user_id

  belongs_to :achievement
  belongs_to :user

  def get_count
    self.count
  end

  private

    def validate_achievement_id
      errors.add(:achievement_id, "is invalid") unless Achievement.exists?(achievement_id)
    end

    def validate_user_id
      errors.add(:user_id, "is invalid") unless User.exists?(user_id)
    end

end
