module StoryAuthorization
  extend ActiveSupport::Concern

  # Make these methods available to views
  included do
    helper_method :user_can_comment_on_story?, :user_can_view_story?
  end

  def user_can_view_story?
    return true unless user_signed_in?

    # User can view if they are the creator or an accepted participant
    @story.creator == current_user ||
    @story.participants.accepted.exists?(user: current_user)
  end

  def user_can_comment_on_story?
    return false unless user_signed_in?

    # User can comment if they are the creator or an accepted participant
    @story.creator == current_user ||
    @story.participants.accepted.exists?(user: current_user)
  end

  private

  def ensure_user_can_view_story
    unless user_can_view_story?
      redirect_to root_path, alert: 'You do not have permission to view this story.'
    end
  end

  def ensure_user_can_comment
    unless user_can_comment_on_story?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_comment_form",
            partial: "comments/unauthorized_message"
          )
        end
        format.html do
          redirect_to @story, alert: 'You are not authorized to comment on this story.'
        end
      end
    end
  end
end
