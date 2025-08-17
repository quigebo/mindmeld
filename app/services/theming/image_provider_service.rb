module Theming
  class ImageProviderService < BaseService
    UNSPLASH_API_URL = 'https://api.unsplash.com/search/photos'
    DEFAULT_IMAGE_URL = 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=800&fit=crop' # Default nature image

    # Image categories for different entity types
    IMAGE_CATEGORIES = {
      'place' => %w[landscape cityscape architecture travel],
      'thing' => %w[object still-life abstract],
      'person' => %w[portrait lifestyle people]
    }.freeze

    def initialize
      @api_key = Rails.application.credentials.unsplash&.access_key
      super()
    end

    # Fetches a background image for the given entity
    def fetch_background_image(entity, options = {})
      return DEFAULT_IMAGE_URL unless @api_key

      log_info("Fetching background image for entity: #{entity.name} (#{entity.entity_type})")

      search_query = build_search_query(entity, options)
      image_data = fetch_from_unsplash(search_query, options)

      if image_data
        image_url = build_image_url(image_data)
        log_info("Successfully fetched image: #{image_url}")
        image_url
      else
        log_warn("No image found for '#{entity.name}', using default")
        DEFAULT_IMAGE_URL
      end
    rescue StandardError => e
      handle_external_api_error('Unsplash', e)
      DEFAULT_IMAGE_URL
    end

    # Fetches multiple images for secondary themes
    def fetch_secondary_images(entities, limit = 3)
      return [] unless @api_key

      entities.first(limit).map do |entity|
        fetch_background_image(entity, { orientation: 'portrait', limit: 1 })
      end.compact
    end

    private

    def build_search_query(entity, options)
      base_query = entity.name

      # Add category-specific terms
      category_terms = IMAGE_CATEGORIES[entity.entity_type] || []
      if category_terms.any?
        base_query += " #{category_terms.sample}"
      end

      # Add any additional search terms
      if options[:additional_terms]
        base_query += " #{options[:additional_terms]}"
      end

      base_query
    end

    def fetch_from_unsplash(query, options)
      params = {
        query: query,
        per_page: options[:limit] || 1,
        orientation: options[:orientation] || 'landscape',
        content_filter: 'high'
      }

      response = make_api_request(params)
      return nil unless response&.dig('results')&.any?

      response['results'].first
    end

    def make_api_request(params)
      uri = URI(UNSPLASH_API_URL)
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Client-ID #{@api_key}"
      request['Accept-Version'] = 'v1'

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == '200'
        JSON.parse(response.body)
      else
        log_error("Unsplash API error: #{response.code} - #{response.body}")
        nil
      end
    rescue JSON::ParserError => e
      log_error("Failed to parse Unsplash API response", e)
      nil
    end

    def build_image_url(image_data)
      # Use the regular size for background images
      image_data.dig('urls', 'regular') || image_data.dig('urls', 'full')
    end

    def log_error(message, error = nil)
      super("[ImageProvider] #{message}", error)
    end

    def log_info(message)
      super("[ImageProvider] #{message}")
    end

    def log_warn(message)
      super("[ImageProvider] #{message}")
    end
  end
end
