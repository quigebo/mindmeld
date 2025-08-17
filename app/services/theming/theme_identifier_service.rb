module Theming
  class ThemeIdentifierService < BaseService
    # Entity types that are most suitable for theming
    THEME_WORTHY_TYPES = %w[place thing].freeze

    # Entity types that are less suitable for theming
    LESS_THEME_WORTHY_TYPES = %w[person].freeze

    def initialize(story)
      @story = story
      super()
    end

    # Identifies the primary theme entity for the story
    def identify_primary_theme
      return nil unless @story.theming_enabled?
      return nil if @story.entities.empty?

      log_info("Identifying primary theme for Story ##{@story.id}")

      # Get all entities with their scores
      scored_entities = score_entities

      # Find the best theme entity
      primary_entity = select_best_theme_entity(scored_entities)

      if primary_entity
        log_info("Selected primary theme: #{primary_entity.name} (#{primary_entity.entity_type})")
      else
        log_info("No suitable theme entity found")
      end

      primary_entity
    end

    # Identifies secondary theme entities for icons
    def identify_secondary_themes(limit = 3)
      return [] unless @story.theming_enabled?
      return [] if @story.entities.empty?

      log_info("Identifying secondary themes for Story ##{@story.id}")

      scored_entities = score_entities
      primary_entity = identify_primary_theme

      # Filter out the primary entity and select top secondary entities
      secondary_entities = scored_entities
        .reject { |entity, _| entity == primary_entity }
        .first(limit)
        .map(&:first)

      log_info("Selected #{secondary_entities.count} secondary themes")
      secondary_entities
    end

    private

    def score_entities
      @story.entities.map do |entity|
        score = calculate_entity_score(entity)
        [entity, score]
      end.sort_by { |_, score| -score }
    end

    def calculate_entity_score(entity)
      score = 0.0

      # Base score from mention count
      score += entity.mention_count * 10

      # Bonus for theme-worthy entity types
      if THEME_WORTHY_TYPES.include?(entity.entity_type)
        score += 50
      elsif LESS_THEME_WORTHY_TYPES.include?(entity.entity_type)
        score += 10
      end

      # Bonus for high confidence mentions
      if entity.average_confidence
        score += entity.average_confidence * 20
      end

      # Bonus for recent mentions (recency bias)
      if entity.last_mentioned_at
        days_since_last_mention = (Time.current - entity.last_mentioned_at) / 1.day
        recency_bonus = [30 - days_since_last_mention, 0].max
        score += recency_bonus
      end

      # Penalty for very generic names
      score -= 20 if generic_entity_name?(entity.name)

      score
    end

    def select_best_theme_entity(scored_entities)
      return nil if scored_entities.empty?

      # First, try to find a theme-worthy entity with good score
      theme_worthy_entity = scored_entities.find do |entity, score|
        THEME_WORTHY_TYPES.include?(entity.entity_type) && score > 30
      end

      return theme_worthy_entity&.first if theme_worthy_entity

      # Fallback to any entity with a decent score
      decent_entity = scored_entities.find { |_, score| score > 20 }
      return decent_entity&.first if decent_entity

      # Last resort: return the highest scoring entity
      scored_entities.first&.first
    end

    def generic_entity_name?(name)
      generic_names = %w[thing stuff item place location person someone anyone]
      generic_names.any? { |generic| name.downcase.include?(generic) }
    end
  end
end
