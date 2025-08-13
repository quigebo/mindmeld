class CommentAnalysisJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id)

    # Skip if already analyzed
    return if comment.is_memory_worthy.present?

    # Analyze the comment
    Llm::CommentAnalyzerService.new(comment).analyze!

    # Extract entities from the comment
    Llm::EntityExtractionService.new(comment).extract!

    # If this comment was marked as memory-worthy, trigger memory synthesis
    if comment.reload.is_memory_worthy?
      MemorySynthesisJob.perform_later(comment.commentable_id)
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Comment #{comment_id} not found for analysis"
  rescue => e
    Rails.logger.error "Failed to analyze comment #{comment_id}: #{e.message}"
    raise e
  end
end
