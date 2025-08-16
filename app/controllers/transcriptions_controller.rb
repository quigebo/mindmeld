class TranscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    audio_file = params[:audio]
    
    if audio_file.blank?
      render json: { error: 'No audio file provided' }, status: :bad_request
      return
    end

    begin
      transcription = WhisperService.transcribe(audio_file)
      render json: { transcription: transcription }
    rescue => e
      Rails.logger.error "Transcription error: #{e.message}"
      render json: { error: 'Transcription failed. Please try again.' }, status: :internal_server_error
    end
  end
end
