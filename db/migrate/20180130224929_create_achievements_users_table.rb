class CreateAchievementsUsersTable < ActiveRecord::Migration
  def up
    create_table :achievements_users, :id => false do |t|
      t.integer :achievement_id
      t.integer :user_id
      t.integer :count
      t.timestamps
    end
  end
  def down
    drop_table :achievements_users
  end
end
