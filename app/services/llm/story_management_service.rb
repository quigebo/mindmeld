module Llm
  class StoryManagementService
    def initialize(story)
      @story = story
    end

    # Manually trigger memory synthesis for a story
    def regenerate_synthesis!
      MemorySynthesisJob.perform_later(@story.id)
    end

    # Re-analyze all comments in a story
    def reanalyze_all_comments!
      @story.comments.where(is_memory_worthy: nil).find_each do |comment|
        CommentAnalysisJob.perform_later(comment.id)
      end
    end

    # Get statistics about LLM processing for a story
    def processing_stats
      total_comments = @story.comments.count
      analyzed_comments = @story.comments.where.not(is_memory_worthy: nil).count
      memory_worthy_comments = @story.comments.memory_worthy.count
      pending_analysis = total_comments - analyzed_comments

      {
        total_comments: total_comments,
        analyzed_comments: analyzed_comments,
        memory_worthy_comments: memory_worthy_comments,
        pending_analysis: pending_analysis,
        has_synthesized_memory: @story.synthesized_memory.present?,
        last_synthesis: @story.synthesized_memory&.generated_at
      }
    end

    # Get memory types distribution
    def memory_types_distribution
      @story.comments.memory_worthy
            .joins(:user)
            .pluck(:llm_analysis)
            .compact
            .map { |analysis| analysis['memory_type'] }
            .compact
            .tally
    end

    # Get participants who have contributed memories
    def memory_contributors
      @story.comments.memory_worthy
            .joins(:user)
            .distinct
            .pluck('users.name', 'users.id')
            .map { |name, id| { name: name, id: id } }
    end
  end
end
