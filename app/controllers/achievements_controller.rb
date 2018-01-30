class AchievementsController < ApplicationController
  before_action :set_achievement, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @achievements = Achievement.all
    respond_with(@achievements)
  end

  def show
    respond_with(@achievement)
  end

  def new
    @achievement = Achievement.new
    respond_with(@achievement)
  end

  def edit
  end

  def create
    @achievement = Achievement.new(achievement_params)
    @achievement.save
    respond_with(@achievement)
  end

  def update
    @achievement.update(achievement_params)
    respond_with(@achievement)
  end

  def destroy
    @achievement.destroy
    respond_with(@achievement)
  end

  private
    def set_achievement
      @achievement = Achievement.find(params[:id])
    end

    def achievement_params
      params.require(:achievement).permit(:name, :points, :description)
    end
end
