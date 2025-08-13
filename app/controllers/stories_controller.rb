class StoriesController < ApplicationController
  before_action :set_story, only: [:show]

  def index
    @stories = Story.includes(:creator, :synthesized_memory).order(created_at: :desc)
  end

  def show
    @comments = @story.comment_threads.memory_worthy.chronological.includes(:user)
    @synthesized_memory = @story.synthesized_memory
    @grouped_entities = Entity.grouped_by_type(@story)
  end

  def new
    @story = Story.new
  end

  def create
    @story = current_user.stories.build(story_params)
    
    if @story.save
      redirect_to @story, notice: 'Story was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(:title, :description, :start_date, :end_date)
  end

  def current_user
    # For now, we'll use a default user. In a real app, you'd have authentication
    User.first || User.create!(name: "Default User", email: "user@example.com")
  end
end
