class MemorySynthesisJob < ApplicationJob
  queue_as :default

  def perform(story_id)
    story = Story.find(story_id)

    # Only synthesize if there are memory-worthy comments
    return if story.comment_threads.memory_worthy.empty?

    # Synthesize the memories
    Llm::MemorySynthesisService.new(story).synthesize!

    Rails.logger.info "Successfully synthesized memories for story #{story_id}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Story #{story_id} not found for memory synthesis"
  rescue => e
    Rails.logger.error "Failed to synthesize memories for story #{story_id}: #{e.message}"
    raise e
  end
end
