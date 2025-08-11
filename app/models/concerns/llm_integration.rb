module LLMIntegration
  extend ActiveSupport::Concern

  # Check if story has pending LLM analysis
  def has_pending_analysis?
    comment_threads.where(is_memory_worthy: nil).exists?
  end

  # Check if story is ready for synthesis
  def ready_for_synthesis?
    comment_threads.memory_worthy.exists?
  end

  # Get the latest synthesized memory with metadata
  def latest_synthesized_memory_with_metadata
    return nil unless synthesized_memory

    {
      content: synthesized_memory.content,
      title: synthesized_memory.metadata&.dig('title'),
      summary: synthesized_memory.metadata&.dig('summary'),
      themes: synthesized_memory.metadata&.dig('themes') || [],
      key_moments: synthesized_memory.metadata&.dig('key_moments') || [],
      generated_at: synthesized_memory.generated_at,
      total_memories: synthesized_memory.metadata&.dig('generation_details', 'total_memories'),
      model_used: synthesized_memory.metadata&.dig('generation_details', 'model_used'),
      version_count: synthesized_memory.versions.count
    }
  end

  # Placeholder methods that will be implemented when LLM services are properly loaded
  def llm_service
    raise NotImplementedError, "LLM services not yet available"
  end

  def regenerate_synthesis!
    raise NotImplementedError, "LLM services not yet available"
  end

  def reanalyze_all_comments!
    raise NotImplementedError, "LLM services not yet available"
  end

  def llm_stats
    raise NotImplementedError, "LLM services not yet available"
  end

  def memory_types_distribution
    raise NotImplementedError, "LLM services not yet available"
  end

  def memory_contributors
    raise NotImplementedError, "LLM services not yet available"
  end
end
