require 'faraday/multipart'

class WhisperService
  def self.transcribe(audio_file)
    new.transcribe(audio_file)
  end

  def transcribe(audio_file)
    response = client.post('/v1/audio/transcriptions') do |req|
      req.body = {
        file: Faraday::FilePart.new(audio_file.path, audio_file.content_type),
        model: 'whisper-1',
        language: 'en'
      }
    end

    handle_response(response)
  end

  private

  def client
    @client ||= Faraday.new('https://api.openai.com') do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter :net_http
      f.headers['Authorization'] = "Bearer #{api_key}"
      f.options.timeout = 30
      f.options.open_timeout = 10
    end
  end

  def handle_response(response)
    case response.status
    when 200
      result = JSON.parse(response.body)
      result['text']
    when 401
      raise "Invalid OpenAI API key"
    when 429
      raise "Rate limit exceeded. Please try again later."
    when 400
      error = JSON.parse(response.body) rescue { 'error' => 'Bad request' }
      raise "OpenAI API error: #{error['error']}"
    else
      Rails.logger.error "Whisper API error: #{response.status} - #{response.body}"
      raise "Whisper API error: #{response.status}"
    end
  end

  def api_key
    Rails.application.credentials.openai[:api_key]
  end
end
