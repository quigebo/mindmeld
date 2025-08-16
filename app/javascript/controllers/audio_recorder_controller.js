import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "progress", "timer", "transcription", "form", "status"]
  static values = { 
    maxDuration: { type: Number, default: 300 }, // 5 minutes in seconds
    isRecording: { type: Boolean, default: false }
  }

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.recordingStartTime = null
    this.recordingInterval = null
    this.speechRecognition = null
    this.isIOS = this.detectIOS()
    this.isWeb = this.detectWeb()
    this.speechRecognitionFailed = false
    
    this.setupSpeechRecognition()
  }

  disconnect() {
    this.stopRecording()
    this.cleanupSpeechRecognition()
  }

  // Platform detection
  detectIOS() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  }

  detectWeb() {
    return !this.isIOS && (window.SpeechRecognition || window.webkitSpeechRecognition)
  }

  // Speech recognition setup for both iOS and Web
  setupSpeechRecognition() {
    if (!this.isIOS && !this.isWeb) {
      this.showUnsupportedBrowserError()
      return
    }

    // Use appropriate SpeechRecognition API
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (SpeechRecognition) {
      this.speechRecognition = new SpeechRecognition()
      this.speechRecognition.continuous = true
      this.speechRecognition.interimResults = true
      this.speechRecognition.lang = 'en-US'
      
      this.speechRecognition.onresult = (event) => {
        let finalTranscript = ''
        let interimTranscript = ''
        
        for (let i = event.resultIndex; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript
          if (event.results[i].isFinal) {
            finalTranscript += transcript
          } else {
            interimTranscript += transcript
          }
        }
        
        this.updateTranscription(finalTranscript, interimTranscript)
      }
      
      this.speechRecognition.onerror = (event) => {
        console.error('Speech recognition error:', event.error)
        this.handleTranscriptionError(event.error)
      }
      
      this.speechRecognition.onend = () => {
        if (this.isRecordingValue) {
          // Restart if still recording
          this.speechRecognition.start()
        }
      }
    }
  }

  // Show error for unsupported browsers (like Firefox)
  showUnsupportedBrowserError() {
    if (this.hasTranscriptionTarget) {
      this.transcriptionTarget.innerHTML = `
        <div class="bg-red-50 border border-red-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">
                Audio recording not supported in this browser
              </h3>
              <div class="mt-2 text-sm text-red-700">
                <p>Please use Chrome, Safari, or Edge for audio recording. You can still type your story below.</p>
              </div>
            </div>
          </div>
        </div>
      `
    }
  }

  // Start recording
  async startRecording() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44100
        } 
      })
      
      this.mediaRecorder = new MediaRecorder(stream, {
        mimeType: 'audio/webm;codecs=opus'
      })
      
      this.audioChunks = []
      this.recordingStartTime = Date.now()
      this.isRecordingValue = true
      
      // Start speech recognition
      if (this.speechRecognition) {
        this.speechRecognition.start()
      }
      
      // Setup recording events
      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }
      
      this.mediaRecorder.onstop = () => {
        this.handleRecordingComplete()
      }
      
      // Start recording
      this.mediaRecorder.start()
      
      // Start timer and progress updates
      this.startTimer()
      this.updateButtonState()
      this.updateStatus(true)
      
    } catch (error) {
      console.error('Error starting recording:', error)
      this.handleRecordingError(error)
    }
  }

  // Stop recording
  stopRecording() {
    if (this.mediaRecorder && this.isRecordingValue) {
      this.mediaRecorder.stop()
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop())
      
      if (this.speechRecognition) {
        this.speechRecognition.stop()
      }
      
      this.isRecordingValue = false
      this.stopTimer()
      this.updateButtonState()
      this.updateStatus(false)
    }
  }

  // Toggle recording (start/stop)
  toggle(event) {
    // Prevent form submission
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isRecordingValue) {
      this.stopRecording()
    } else {
      this.startRecording()
    }
  }

  // Timer management
  startTimer() {
    this.recordingInterval = setInterval(() => {
      const elapsed = Math.floor((Date.now() - this.recordingStartTime) / 1000)
      const remaining = this.maxDurationValue - elapsed
      
      this.updateProgress(elapsed)
      this.updateTimer(remaining)
      
      if (remaining <= 0) {
        this.stopRecording()
      }
    }, 100)
  }

  stopTimer() {
    if (this.recordingInterval) {
      clearInterval(this.recordingInterval)
      this.recordingInterval = null
    }
  }

  // Visual updates
  updateProgress(elapsed) {
    if (this.hasProgressTarget) {
      const progress = (elapsed / this.maxDurationValue) * 100
      const circumference = 2 * Math.PI * 45 // Assuming radius of 45
      const offset = circumference - (progress / 100) * circumference
      
      this.progressTarget.style.strokeDasharray = circumference
      this.progressTarget.style.strokeDashoffset = offset
    }
  }

  updateTimer(remaining) {
    if (this.hasTimerTarget) {
      const minutes = Math.floor(remaining / 60)
      const seconds = remaining % 60
      this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`
    }
  }

  updateButtonState() {
    if (this.hasButtonTarget) {
      if (this.isRecordingValue) {
        this.buttonTarget.classList.add('recording')
        this.buttonTarget.innerHTML = this.stopIcon()
      } else {
        this.buttonTarget.classList.remove('recording')
        this.buttonTarget.innerHTML = this.recordIcon()
      }
    }
  }

  updateStatus(isRecording) {
    if (this.hasStatusTarget) {
      if (isRecording) {
        this.statusTarget.classList.remove('opacity-0')
        this.statusTarget.classList.add('opacity-100')
      } else {
        this.statusTarget.classList.remove('opacity-100')
        this.statusTarget.classList.add('opacity-0')
      }
    }
  }

  updateTranscription(final, interim = '') {
    if (this.hasTranscriptionTarget) {
      const displayText = final + (interim ? ` <span class="interim">${interim}</span>` : '')
      this.transcriptionTarget.innerHTML = displayText
      
      // Update form field if connected
      if (this.hasFormTarget) {
        const formField = this.formTarget.querySelector('textarea, input[type="text"]')
        if (formField) {
          formField.value = final
        }
      }
    }
  }

  // Handle recording completion with Whisper fallback
  async handleRecordingComplete() {
    // If we have audio chunks, try Whisper API regardless of transcription status
    const hasAudio = this.audioChunks.length > 0
    const hasTranscription = this.transcriptionTarget && this.transcriptionTarget.textContent.trim() !== ''
    
    if (hasAudio) {
      console.log('Recording completed, audio chunks:', this.audioChunks.length)
      console.log('Speech recognition failed:', this.speechRecognitionFailed)
      console.log('Has transcription:', hasTranscription)
      
      // Try Whisper if speech recognition failed or if we have no transcription
      if (this.speechRecognitionFailed || !hasTranscription) {
        console.log('Trying Whisper API...')
        await this.processWithWhisper()
      } else {
        console.log('Transcription already available from speech recognition')
      }
    } else {
      console.log('No audio chunks available for processing')
    }
  }

  // Process audio with Whisper API
  async processWithWhisper() {
    try {
      console.log('Starting Whisper API processing...')
      this.showProcessingMessage()
      
      const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
      console.log('Audio blob created:', audioBlob.size, 'bytes')
      
      const formData = new FormData()
      formData.append('audio', audioBlob, 'recording.webm')
      
      console.log('Sending request to /transcriptions...')
      const response = await fetch('/transcriptions', {
        method: 'POST',
        body: formData
      })
      
      console.log('Response status:', response.status)
      
      if (response.ok) {
        const result = await response.json()
        console.log('Whisper API success:', result)
        this.updateTranscription(result.transcription)
      } else {
        const error = await response.json()
        console.error('Whisper API error:', error)
        this.showWhisperError(error.error || 'Transcription failed')
      }
    } catch (error) {
      console.error('Whisper API error:', error)
      this.showWhisperError('Network error. Please try again.')
    }
  }

  // Show processing message
  showProcessingMessage() {
    if (this.hasTranscriptionTarget) {
      this.transcriptionTarget.innerHTML = `
        <div class="bg-blue-50 border border-blue-200 rounded-md p-4">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="animate-spin h-5 w-5 text-blue-400" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-blue-800">
                Processing your audio...
              </h3>
              <p class="text-sm text-blue-700">This may take a few seconds.</p>
            </div>
          </div>
        </div>
      `
    }
  }

  // Show Whisper API error
  showWhisperError(message) {
    if (this.hasTranscriptionTarget) {
      this.transcriptionTarget.innerHTML = `
        <div class="bg-red-50 border border-red-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">
                ${message}
              </h3>
              <p class="text-sm text-red-700">You can still type your story below.</p>
            </div>
          </div>
        </div>
      `
    }
  }

  // Icon helpers
  recordIcon() {
    return `
      <svg class="w-12 h-12 text-blue-500" fill="currentColor" viewBox="0 0 24 24">
        <path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3z"/>
        <path d="M17 11c0 2.76-2.24 5-5 5s-5-2.24-5-5H5c0 3.53 2.61 6.43 6 6.92V21h2v-3.08c3.39-.49 6-3.39 6-6.92h-2z"/>
      </svg>
    `
  }

  stopIcon() {
    return `
      <svg class="w-12 h-12 text-red-500" fill="currentColor" viewBox="0 0 24 24">
        <path d="M6 6h12v12H6z"/>
      </svg>
    `
  }

  // Error handling
  handleRecordingError(error) {
    console.error('Recording error:', error)
    
    let errorMessage = 'Recording failed. Please try again.'
    if (error.name === 'NotAllowedError') {
      errorMessage = 'Microphone access denied. Please allow microphone access and try again.'
    } else if (error.name === 'NotFoundError') {
      errorMessage = 'No microphone found. Please connect a microphone and try again.'
    }
    
    if (this.hasTranscriptionTarget) {
      this.transcriptionTarget.innerHTML = `
        <div class="bg-red-50 border border-red-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">
                ${errorMessage}
              </h3>
            </div>
          </div>
        </div>
      `
    }
  }

  handleTranscriptionError(error) {
    console.error('Transcription error:', error)
    
    let errorMessage = 'Transcription failed. Please try again.'
    let showRetry = false
    let triggerWhisper = false
    
    if (error === 'network') {
      errorMessage = 'Network error with speech recognition. Trying server-side transcription...'
      showRetry = true
      triggerWhisper = true
      this.speechRecognitionFailed = true
    } else if (error === 'not-allowed') {
      errorMessage = 'Microphone access denied. Please allow microphone access and try again.'
    } else if (error === 'no-speech') {
      errorMessage = 'No speech detected. Please try speaking again.'
      showRetry = true
    } else if (error === 'audio-capture') {
      errorMessage = 'Audio capture failed. Please check your microphone and try again.'
    } else if (error === 'service-not-allowed') {
      errorMessage = 'Speech recognition service not allowed. Please check your browser settings.'
    }
    
    // If we have audio chunks and speech recognition failed, try Whisper immediately
    if (triggerWhisper && this.audioChunks.length > 0) {
      this.processWithWhisper()
      return
    }
    
    if (this.hasTranscriptionTarget) {
      const retryButton = showRetry ? `
        <button onclick="location.reload()" class="mt-2 px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 transition-colors">
          Retry
        </button>
      ` : ''
      
      this.transcriptionTarget.innerHTML = `
        <div class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">
                ${errorMessage}
              </h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p>You can still type your story below, or try refreshing the page.</p>
                ${retryButton}
              </div>
            </div>
          </div>
        </div>
      `
    }
  }

  cleanupSpeechRecognition() {
    if (this.speechRecognition) {
      this.speechRecognition.stop()
    }
  }
}
