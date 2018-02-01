class CreateAchievementsUsersTable < ActiveRecord::Migration
  def up
    create_table :achievements_users do |t|
      t.integer :achievement_id
      t.integer :user_id
      t.integer :count, default: 0
      t.timestamps
    end
    add_index :achievements_users, [:achievement_id, :user_id], unique: true
  end
  def down
    drop_table :achievements_users
  end
end
