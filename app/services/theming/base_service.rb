module Theming
  class BaseService
    private

    def log_info(message)
      Rails.logger.info "[Theming] #{message}"
    end

    def log_error(message, error = nil)
      Rails.logger.error "[Theming] #{message}"
      Rails.logger.error "[Theming] Error: #{error.message}" if error
      Rails.logger.error "[Theming] Backtrace: #{error.backtrace.first(5).join("\n")}" if error&.backtrace
    end

    def log_warn(message)
      Rails.logger.warn "[Theming] #{message}"
    end

    def handle_external_api_error(service_name, error)
      log_error("#{service_name} API error", error)
      # In the future, we could send this to an error tracking service
      # Sentry.capture_exception(error) if defined?(Sentry)
    end

    def safe_execute(operation_name)
      yield
    rescue StandardError => e
      log_error("#{operation_name} failed", e)
      nil
    end
  end
end
