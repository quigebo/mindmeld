class LLM::MemorySynthesisService
  include ActiveSupport::Configurable

  # Schema for structured output from memory synthesis
  class SynthesisSchema < RubyLLM::Schema
    string :narrative, description: "The synthesized narrative in third-person perspective"
    string :title, description: "A compelling title for the synthesized story"
    string :summary, description: "A brief summary of the key events and themes"
    array :themes, description: "Main themes that emerge from the memories" do
      string description: "A theme or motif from the story"
    end
    array :key_moments, description: "The most significant moments or turning points" do
      string description: "A key moment or event"
    end
    object :metadata, description: "Additional metadata about the synthesis" do
      number :total_memories, description: "Number of memories used"
      number :time_span_days, description: "Time span covered in days"
      string :primary_location, description: "Primary location if identifiable"
    end
  end

  def initialize(story)
    @story = story
    @memory_comments = story.comments.memory_worthy.chronological
  end

  def synthesize!
    return if @memory_comments.empty?

    synthesis = perform_synthesis
    create_synthesized_memory(synthesis)
  rescue => e
    Rails.logger.error "Failed to synthesize memories for story #{@story.id}: #{e.message}"
    raise e
  end

  private

  def perform_synthesis
    chat = RubyLLM.chat
    chat.with_schema(SynthesisSchema)
        .ask(synthesis_prompt)
  end

  def synthesis_prompt
    <<~PROMPT
      Synthesize these collaborative memories into a cohesive, engaging narrative from a third-person perspective.

      STORY CONTEXT:
      Title: #{@story.title}
      Description: #{@story.description}
      Time Period: #{@story.start_date} to #{@story.end_date}

      MEMORIES TO SYNTHESIZE:
      #{format_memories_for_prompt}

      SYNTHESIS REQUIREMENTS:
      - Write in third-person perspective (e.g., "They arrived at the restaurant...")
      - Create a flowing narrative that connects the memories chronologically
      - Maintain the authentic voice and details from the original memories
      - Include emotional context and relationships between people
      - Highlight the most memorable and significant moments
      - Create a compelling title that captures the essence of the story
      - Provide a brief summary of key events and themes
      - Identify recurring themes and motifs
      - List the most important moments or turning points

      The narrative should read like a well-crafted story that captures the shared experience while preserving the authenticity of the original memories.
    PROMPT
  end

  def format_memories_for_prompt
    @memory_comments.map.with_index do |comment, index|
      analysis = comment.llm_analysis || {}

      <<~MEMORY
        MEMORY #{index + 1}:
        Author: #{comment.user.name}
        When: #{comment.occurred_at || comment.created_at}
        Location: #{comment.location || 'Not specified'}
        Type: #{analysis['memory_type'] || 'unknown'}
        Content: #{comment.body}
        Key Details: #{Array(analysis['key_details']).join(', ')}
        ---
      MEMORY
    end.join("\n")
  end

  def create_synthesized_memory(synthesis)
    content = synthesis.content

    # Create or update the synthesized memory
    memory = @story.synthesized_memory || @story.build_synthesized_memory

    memory.update!(
      content: content[:narrative],
      metadata: {
        title: content[:title],
        summary: content[:summary],
        themes: content[:themes],
        key_moments: content[:key_moments],
        metadata: content[:metadata],
        included_comment_ids: @memory_comments.pluck(:id),
        generation_details: {
          model_used: RubyLLM.config.default_model,
          generated_at: Time.current,
          total_memories: @memory_comments.count,
          memory_types: @memory_comments.map { |c| c.llm_analysis&.dig('memory_type') }.compact.uniq
        }
      }
    )

    memory
  end
end
