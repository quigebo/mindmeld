module Theming
  class ThemeAnalysisJob < ApplicationJob
    queue_as :default

    def perform(story_id)
      story = Story.find(story_id)

      return unless story.theming_enabled?

      log_info("Starting theme analysis for Story ##{story_id}")

      # Store the previous theme data to check if it changed
      previous_theme_data = get_current_theme_data(story)

      # Use the theme management service to analyze and update the theme
      theme_service = ThemeManagementService.new(story)
      theme_service.analyze_and_update_theme

      # Get the new theme data
      new_theme_data = get_current_theme_data(story)

      # Check if the theme actually changed
      if theme_changed?(previous_theme_data, new_theme_data)
        log_info("Theme changed for Story ##{story_id}, broadcasting update")
        # Broadcast in all environments except test
        broadcast_theme_update(story) if should_broadcast?
      else
        log_info("No theme change detected for Story ##{story_id}")
      end

      log_info("Theme analysis completed for Story ##{story_id}")
    rescue ActiveRecord::RecordNotFound => e
      log_error("Story ##{story_id} not found", e)
    rescue StandardError => e
      log_error("Theme analysis failed for Story ##{story_id}", e)
      # Re-raise to trigger job retry mechanism
      raise
    end

    private

    def should_broadcast?
      # Broadcast in development and production, but not in test environment
      # This allows for real-time development experience while avoiding test complications
      !Rails.env.test?
    end

    def get_current_theme_data(story)
      theme_service = ThemeManagementService.new(story)
      theme_service.current_theme_data
    end

    def theme_changed?(previous_data, new_data)
      return true if previous_data.nil? && new_data.present?
      return true if previous_data.present? && new_data.nil?
      return false if previous_data.nil? && new_data.nil?

      # Compare background image URLs
      previous_data[:background_image_url] != new_data[:background_image_url]
    end

    def broadcast_theme_update(story)
      theme_data = get_current_theme_data(story)

      # Broadcast to all users viewing this story
      Turbo::StreamsChannel.broadcast_update_to(
        "story_#{story.id}",
        target: "theme_background",
        partial: "stories/theme_background",
        locals: {
          theme_data: theme_data
        }
      )

      # Also broadcast the content update
      Turbo::StreamsChannel.broadcast_update_to(
        "story_#{story.id}",
        target: "story_content",
        partial: "stories/content_sections",
        locals: {
          story: story,
          theme_data: theme_data,
          grouped_entities: Entity.grouped_by_type(story),
          synthesized_memory: story.synthesized_memory,
          comments: story.comment_threads.chronological
        }
      )
    end

    def log_info(message)
      Rails.logger.info "[ThemeAnalysisJob] #{message}"
    end

    def log_error(message, error = nil)
      Rails.logger.error "[ThemeAnalysisJob] #{message}"
      Rails.logger.error "[ThemeAnalysisJob] Error: #{error.message}" if error
    end
  end
end
