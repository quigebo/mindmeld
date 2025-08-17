module Theming
  class ThemeManagementService < BaseService
    def initialize(story)
      @story = story
      @theme_identifier = ThemeIdentifierService.new(story)
      @image_provider = ImageProviderService.new
      super()
    end

    # Analyzes the story and updates its theme
    def analyze_and_update_theme
      return unless @story.theming_enabled?

      log_info("Starting theme analysis for Story ##{@story.id}")

      # Identify primary theme entity
      primary_entity = @theme_identifier.identify_primary_theme
      return unless primary_entity

      # Fetch background image
      background_image_url = @image_provider.fetch_background_image(primary_entity)

      # Identify secondary themes for icons
      secondary_entities = @theme_identifier.identify_secondary_themes(3)
      secondary_images = @image_provider.fetch_secondary_images(secondary_entities)

      # Update or create story theme
      update_story_theme(primary_entity, background_image_url, secondary_images)

      log_info("Theme analysis completed for Story ##{@story.id}")
    end

    # Forces a theme refresh for the story
    def refresh_theme
      log_info("Forcing theme refresh for Story ##{@story.id}")
      analyze_and_update_theme
    end

    # Gets the current theme data for the story
    def current_theme_data
      return nil unless @story.story_theme

      {
        primary_entity: @story.story_theme.source_entity,
        background_image_url: @story.story_theme.background_image_url,
        icon_pack: @story.story_theme.icon_pack,
        metadata: @story.story_theme.metadata
      }
    end

    # Checks if the story has a valid theme
    def has_valid_theme?
      return false unless @story.story_theme
      @story.story_theme.has_background_image?
    end

    private

    def update_story_theme(primary_entity, background_image_url, secondary_images = [])
      theme_data = {
        source_entity: primary_entity,
        background_image_url: background_image_url,
        metadata: {
          'analyzed_at' => Time.current.iso8601,
          'secondary_images' => secondary_images,
          'theme_score' => calculate_theme_score(primary_entity)
        }
      }

      if @story.story_theme
        @story.story_theme.update!(theme_data)
        log_info("Updated existing theme for Story ##{@story.id}")
      else
        @story.create_story_theme!(theme_data)
        log_info("Created new theme for Story ##{@story.id}")
      end
    rescue StandardError => e
      log_error("Failed to update story theme", e)
      raise
    end

    def calculate_theme_score(entity)
      # Calculate a confidence score for the theme
      score = 0.0

      # Base score from mention count
      score += entity.mention_count * 10

      # Bonus for theme-worthy types
      if ThemeIdentifierService::THEME_WORTHY_TYPES.include?(entity.entity_type)
        score += 50
      end

      # Bonus for high confidence
      if entity.average_confidence
        score += entity.average_confidence * 20
      end

      score
    end

    def log_error(message, error = nil)
      super("[ThemeManagement] #{message}", error)
    end

    def log_info(message)
      super("[ThemeManagement] #{message}")
    end
  end
end
