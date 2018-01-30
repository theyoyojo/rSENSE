class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :name
      t.decimal :points
      t.string :description

      t.timestamps
    end
  end
end
