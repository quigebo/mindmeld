# # Configure RubyLLM for AI-powered features
RubyLLM.configure do |config|
  # OpenAI configuration (primary LLM provider)
  config.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
  config.openai_organization_id = ENV.fetch('OPENAI_ORGANIZATION_ID', nil) # Billing organization
  config.openai_project_id = ENV.fetch('OPENAI_PROJECT_ID', nil)           # Usage tracking

  # Anthropic configuration (alternative provider)
  # config.anthropic_api_key = ENV.fetch('ANTHROPIC_API_KEY', nil)

  # Default model configuration
  config.default_model = ENV.fetch('DEFAULT_LLM_MODEL', 'gpt-5-mini')

  # Request timeout (in seconds)
  config.request_timeout = ENV.fetch('LLM_TIMEOUT', 120).to_i

  # Retry configuration
  config.max_retries = ENV.fetch('LLM_MAX_RETRIES', 3).to_i
  config.retry_interval = ENV.fetch('LLM_RETRY_DELAY', 1).to_f

  # Logging configuration
  config.log_level = Rails.env.development? ? :debug : :info
  config.log_stream_debug = true
end
