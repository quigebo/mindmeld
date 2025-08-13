module Llm
  class EntityExtractionService
    include ActiveSupport::Configurable

    # Configuration
    MIN_CONFIDENCE_THRESHOLD = 0.5

    # Schema for structured output from entity extraction
    class EntityExtractionSchema < RubyLLM::Schema
      array :people, description: "People mentioned in the memory" do
        object do
          string :name, description: "Full name of the person"
          string :relationship, description: "Relationship to the author (friend, family, colleague, etc.)"
          number :confidence, description: "Confidence score 0-1"
        end
      end

      array :places, description: "Places mentioned in the memory" do
        object do
          string :name, description: "Name of the place"
          string :type, description: "Type of place (restaurant, park, city, etc.)"
          number :confidence, description: "Confidence score 0-1"
        end
      end

      array :things, description: "Important objects, activities, or events mentioned" do
        object do
          string :name, description: "Name of the thing"
          string :category, description: "Category (object, activity, event, emotion, etc.)"
          number :confidence, description: "Confidence score 0-1"
        end
      end
    end

    def initialize(comment)
      @comment = comment
      @story = comment.commentable
    end

    def extract!
      return if @comment.body.blank?

      extraction = perform_extraction
      process_extraction(extraction)
    rescue => e
      Rails.logger.error "Failed to extract entities for comment #{@comment.id}: #{e.message}"
      raise e
    end

    private

    def perform_extraction
      chat = RubyLLM.chat(model: 'gpt-5-mini').with_temperature(1.0)
      chat.with_schema(EntityExtractionSchema)
        .ask(extraction_prompt)
    end

    def extraction_prompt
      <<~PROMPT
      Extract entities from this memory/comment. Focus on identifying people, places, and important things mentioned.

      COMMENT:
      #{@comment.body}

      STORY CONTEXT:
      Title: #{@story.title}
      Description: #{@story.description}

      EXTRACTION REQUIREMENTS:
      - Extract people mentioned by name (first name, full name, or nickname)
      - Extract places mentioned (restaurants, cities, parks, venues, etc.)
      - Extract important objects, activities, or events mentioned
      - Only include entities that are clearly mentioned in the text
      - Provide confidence scores based on how clearly the entity is mentioned
      - Filter out generic terms like "we", "they", "here", "there" unless they refer to specific people or places
      - For people, try to identify relationships if mentioned
      - For places, identify the type of place if clear
      - For things, categorize them appropriately

      Be conservative with confidence scores - only give high scores to clearly identified entities.
      PROMPT
    end

    def process_extraction(extraction)
      content = extraction.content.with_indifferent_access
      
      # Process people
      content[:people]&.each do |person|
        next if person[:confidence] < MIN_CONFIDENCE_THRESHOLD
        
        entity = Entity.find_or_create_for_story(
          @story,
          person[:name],
          'person',
          person[:confidence]
        )
        
        # Create the comment entity association
        entity.comment_entities.find_or_create_by(
          comment: @comment,
          confidence_score: person[:confidence]
        )
      end

      # Process places
      content[:places]&.each do |place|
        next if place[:confidence] < MIN_CONFIDENCE_THRESHOLD
        
        entity = Entity.find_or_create_for_story(
          @story,
          place[:name],
          'place',
          place[:confidence]
        )
        
        entity.comment_entities.find_or_create_by(
          comment: @comment,
          confidence_score: place[:confidence]
        )
      end

      # Process things
      content[:things]&.each do |thing|
        next if thing[:confidence] < MIN_CONFIDENCE_THRESHOLD
        
        entity = Entity.find_or_create_for_story(
          @story,
          thing[:name],
          'thing',
          thing[:confidence]
        )
        
        entity.comment_entities.find_or_create_by(
          comment: @comment,
          confidence_score: thing[:confidence]
        )
      end

      # Return summary of extracted entities
      {
        people: content[:people]&.size || 0,
        places: content[:places]&.size || 0,
        things: content[:things]&.size || 0,
        total: (content[:people]&.size || 0) + (content[:places]&.size || 0) + (content[:things]&.size || 0)
      }
    end
  end
end
