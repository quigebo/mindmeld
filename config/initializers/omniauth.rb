Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.application.credentials.google&.dig(:web, :client_id).present?
    provider :google_oauth2, 
      Rails.application.credentials.google[:web][:client_id],
      Rails.application.credentials.google[:web][:client_secret],
      {
        scope: 'email,profile',
        prompt: 'select_account'
      }
  end
end
