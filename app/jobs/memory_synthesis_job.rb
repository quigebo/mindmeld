class MemorySynthesisJob < ApplicationJob
  queue_as :default

  def perform(story_id)
    story = Story.find(story_id)

    # Only synthesize if there are memory-worthy comments
    return if story.comments.memory_worthy.empty?

    # Synthesize the memories
    LLM::MemorySynthesisService.new(story).synthesize!

    Rails.logger.info "Successfully synthesized memories for story #{story_id}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Story #{story_id} not found for memory synthesis"
  rescue => e
    Rails.logger.error "Failed to synthesize memories for story #{story_id}: #{e.message}"
    raise e
  end
end
