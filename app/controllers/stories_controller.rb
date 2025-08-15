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
    @intent = params[:intent] || session[:primary_intent]
    @additional_intents = session[:additional_intents] || []
    
    # Set personalized messaging based on intent
    @intent_messaging = case @intent
    when 'remember_stories'
      {
        title: "Let's recover those forgotten details together",
        subtitle: "What story would you like to remember?",
        placeholder: "Start with what you remember, even if it's just fragments..."
      }
    when 'reconnect_friends'
      {
        title: "Reconnect through the power of shared stories",
        subtitle: "What story connects you with someone special?",
        placeholder: "Tell us about a moment that brought you closer together..."
      }
    when 'preserve_memories'
      {
        title: "Create a lasting legacy for future generations",
        subtitle: "What story do you want to preserve forever?",
        placeholder: "Share a story that future generations should know..."
      }
    when 'create_stories'
      {
        title: "Transform raw experiences into something beautiful",
        subtitle: "What story would you like to craft together?",
        placeholder: "Start with the experience you want to turn into a story..."
      }
    else
      {
        title: "Share your story",
        subtitle: "What would you like to remember?",
        placeholder: "Tell us about a moment, experience, or memory..."
      }
    end
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
