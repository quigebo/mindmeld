class StoriesController < ApplicationController
  include StoryAuthorization

  before_action :authenticate_user!, except: [:new]
  before_action :set_story, only: [:show, :update_theme]
  before_action :ensure_user_can_view_story, only: [:show, :update_theme]

  def index
    # Get both stories the user created and stories they participate in
    created_stories = current_user&.created_stories || []
    participated_stories = current_user&.stories || []

    # Combine and remove duplicates (in case user is both creator and participant)
    @stories = (created_stories + participated_stories).uniq.sort_by(&:created_at).reverse
  end

  def show
    @grouped_entities = Entity.grouped_by_type(@story)
    @synthesized_memory = @story.synthesized_memory
    @comments = @story.comment_threads.chronological

    # Add theme data for the view
    @theme_data = get_theme_data
  end

  def update_theme
    # Force a theme refresh
    theme_service = Theming::ThemeManagementService.new(@story)
    theme_service.refresh_theme

    # Reload the story and get updated data
    @story.reload
    @grouped_entities = Entity.grouped_by_type(@story)
    @synthesized_memory = @story.synthesized_memory
    @comments = @story.comment_threads.chronological
    @theme_data = get_theme_data

    respond_to do |format|
      format.turbo_stream do
        render :update_theme
      end
    end
  end

  def new
    @story = Story.new
    @intent_messaging = get_intent_messaging(params[:intent])
  end

  def create
    @story = current_user.created_stories.build(story_params)

    if @story.save
      redirect_to @story, notice: 'Story was successfully created.'
    else
      @intent_messaging = get_intent_messaging(params[:intent])
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(:title, :description)
  end

  def get_theme_data
    return nil unless @story.theming_enabled?

    theme_service = Theming::ThemeManagementService.new(@story)
    theme_service.current_theme_data
  end

  def get_intent_messaging(intent)
    case intent
    when 'remember_stories'
      {
        title: 'Remember Stories You Forgot',
        subtitle: 'Let\'s piece together the memories you thought were lost',
        placeholder: 'Start with what you remember, even if it\'s just fragments...'
      }
    when 'reconnect_friends'
      {
        title: 'Reconnect with Friends',
        subtitle: 'Create something beautiful together and rediscover each other',
        placeholder: 'Tell me about the people you want to reconnect with...'
      }
    when 'preserve_memories'
      {
        title: 'Preserve Family Stories',
        subtitle: 'Capture the stories that future generations need to hear',
        placeholder: 'Share the family story you want to preserve forever...'
      }
    when 'create_stories'
      {
        title: 'Create Beautiful Stories Together',
        subtitle: 'Turn your memories into something magical with your crew',
        placeholder: 'What story do you want to create with your friends?'
      }
    else
      {
        title: 'Create Your Story',
        subtitle: 'Let\'s turn your memories into something beautiful',
        placeholder: 'Start with what comes to mind...'
      }
    end
  end
end
