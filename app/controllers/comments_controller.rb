class CommentsController < ApplicationController
  before_action :set_story

  def create
    @comment = @story.comment_threads.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("comments", partial: "comments/comment", locals: { comment: @comment }),
            turbo_stream.update("new_comment_form", partial: "comments/form", locals: { story: @story, comment: Comment.new })
          ]
        end
        format.html { redirect_to @story, notice: 'Comment was successfully added.' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_comment_form", 
            partial: "comments/form", 
            locals: { story: @story, comment: @comment }
          )
        end
        format.html { redirect_to @story, alert: 'Failed to add comment.' }
      end
    end
  end

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :location, :occurred_at)
  end

  def current_user
    # For now, we'll use a default user. In a real app, you'd have authentication
    User.first || User.create!(name: "Default User", email: "user@example.com")
  end
end
