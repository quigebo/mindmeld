class PagesController < ApplicationController
  def home
    # This will be our landing page with value proposition selection
  end

  def select_intent
    # Handle intent selection and redirect to appropriate onboarding flow
    intent = params[:intent]
    additional_intents = params[:additional_intents]&.reject(&:blank?)
    
    # Store the selected intent(s) in session for use during onboarding
    session[:primary_intent] = intent
    session[:additional_intents] = additional_intents
    
    # Redirect to the appropriate onboarding flow based on intent
    case intent
    when 'remember_stories'
      redirect_to new_story_path(intent: 'remember_stories')
    when 'reconnect_friends'
      redirect_to new_story_path(intent: 'reconnect_friends')
    when 'preserve_memories'
      redirect_to new_story_path(intent: 'preserve_memories')
    when 'create_stories'
      redirect_to new_story_path(intent: 'create_stories')
    else
      redirect_to new_story_path(intent: 'general')
    end
  end
end
