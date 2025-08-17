class EntitiesController < ApplicationController
  include StoryAuthorization

  before_action :set_story
  before_action :ensure_user_can_view_story
  before_action :set_entity

  def show
    @comments = @entity.mentioned_comments.includes(:user).order(:created_at)
  end

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def set_entity
    @entity = @story.entities.find(params[:id])
  end
end
