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

  // Speech recognition setup for iOS
  setupSpeechRecognition() {
    if (!this.isIOS) return

    // Use webkitSpeechRecognition for iOS Safari
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
  }

  handleRecordingComplete() {
    // Audio recording is complete, but transcription may continue
  }

  cleanupSpeechRecognition() {
    if (this.speechRecognition) {
      this.speechRecognition.stop()
    }
  }
}
