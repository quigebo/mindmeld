module Llm
  class CommentAnalyzerService
    include ActiveSupport::Configurable

    # Schema for structured output from LLM analysis
    class AnalysisSchema < RubyLLM::Schema
      boolean :is_memory_worthy, description: "Whether this comment contains a substantive memory worth including in the final story"
      string :reasoning, description: "Detailed reasoning for the memory-worthiness decision"
      string :memory_type, description: "Type of memory (e.g., 'event', 'conversation', 'observation', 'feeling', 'other')"
      number :confidence, description: "Confidence level 0-1 for the analysis"
      array :key_details, description: "Key details or facts mentioned in the comment" do
        string description: "A specific detail or fact"
      end
    end

  def initialize(comment)
    @comment = comment
    @story = comment.commentable
    @user = comment.user
  end

  def analyze!
    return if @comment.is_memory_worthy.present?

    analysis = perform_analysis
    update_comment_with_analysis(analysis)
  rescue => e
    Rails.logger.error "Failed to analyze comment #{@comment.id}: #{e.message}"
    @comment.update!(
      is_memory_worthy: false,
      llm_analysis: { error: e.message, analyzed_at: Time.current }
    )
  end

  private

  # TODO: add a system prompt #with_instructions
  def perform_analysis
    chat = RubyLLM.chat.with_temperature(1.0)
    chat.with_schema(AnalysisSchema)
        .ask(analysis_prompt)
  end

  def analysis_prompt
    <<~PROMPT
      Analyze this comment from a collaborative story to determine if it contains a substantive memory worth including in the final narrative.

      STORY CONTEXT:
      Title: #{@story.title}
      Description: #{@story.description}
      Start Date: #{@story.start_date}
      End Date: #{@story.end_date}

      COMMENT TO ANALYZE:
      Author: #{@user.name}
      Posted: #{@comment.created_at}
      When it happened: #{@comment.occurred_at || 'Not specified'}
      Location: #{@comment.location || 'Not specified'}
      Subject: #{@comment.subject || 'No subject'}
      Content: #{@comment.body}

      ANALYSIS CRITERIA:
      - A memory is "worthy" if it contains specific details, events, conversations, observations, or feelings that contribute to the story
      - Consider the temporal context (when it happened vs when posted)
      - Consider the location context if provided
      - Look for concrete details, emotions, interactions, or memorable moments
      - Exclude general comments, questions, or non-substantive responses
      - Consider the relationship to the story's theme and timeline

      Please analyze this comment and provide structured output with your reasoning.
    PROMPT
  end

  def update_comment_with_analysis(analysis)
    content = analysis.content.with_indifferent_access

    if content[:is_memory_worthy]
      @comment.mark_as_memory_worthy!(
        reasoning: content[:reasoning],
        memory_type: content[:memory_type],
        confidence: content[:confidence],
        key_details: content[:key_details],
        analyzed_at: Time.current
      )
    else
      @comment.mark_as_not_memory_worthy!(
        content[:reasoning]
      )
    end
  end
  end
end
