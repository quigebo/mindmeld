# User Registration and Onboarding Product Requirements Document (PRD)

## Overview

The registration and onboarding flow transforms new users into collaborative storytellers by understanding their intent and guiding them through initial story setup. The goal is to create an "ah-ha" moment where users experience the magic of AI-synthesized collaborative storytelling while learning the platform's core value proposition.

## Core Value Proposition

**Transform scattered memories into cohesive, collaborative narratives.** Users create shared stories, invite friends to contribute their perspectives, and watch AI synthesize everything into a beautiful, third-person narrative that captures the full richness of the collective experience.

## User Personas

### Primary Persona: The Memory Keeper
- **Demographics**: 25-45 years old, socially connected
- **Motivation**: Wants to preserve and share meaningful experiences
- **Pain Points**: Memories fade, details get lost, different perspectives are forgotten
- **Goals**: Create lasting records of important moments, capture multiple viewpoints

### Secondary Persona: The Social Connector
- **Demographics**: 20-35 years old, highly social
- **Motivation**: Wants to strengthen relationships through shared experiences
- **Pain Points**: Hard to coordinate group activities, difficult to maintain connections
- **Goals**: Create shared experiences, strengthen bonds with friends/family

## Entry Points

### 1. Event-First Path
**User Intent**: "I want to tell the story of [specific event]"
**Flow**: Event → People → Guided Story Development

### 2. People-First Path
**User Intent**: "I want to create a story with [specific people]"
**Flow**: People → Relationship Context → Event Discovery → Guided Story Development

### 3. Prompt-First Path
**User Intent**: "I'm not sure where to begin"
**Flow**: Choose from curated prompts → People → Event → Guided Story Development

## Initial User Flows

### Event-First Onboarding Flow

#### Step 1: Event Selection
- **Prompt**: "What story do you want to tell?"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Examples**: "Our camping trip last summer", "The night we got lost in the city", "My 30th birthday party"
- **Validation**: Minimum 3 words, maximum 100 characters after transcription

#### Step 2: People Identification
- **Prompt**: "Who was there?"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Helper Text**: "Think about who made this moment special. You can add more people later."

#### Step 3: Foundation Building (Steps 1-3 of Story Framework)
**Step 3a: Who Details**
- **Prompt**: "Tell me more about the people involved"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Questions**:
  - Names, roles, relationships
  - Any quirks or standout traits?
  - How did everyone know each other?

**Step 3b: Where and When**
- **Prompt**: "Set the scene for your story"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Questions**:
  - Describe the place (rough or exact location)
  - Time of day, season, atmosphere
  - If multi-location, add stops along the way

**Step 3c: Story Arc**
- **Prompt**: "What's the shape of your story?"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Questions**:
  - If single location: Beginning, middle, and end
  - If multi-location: Is the journey sufficient for the arc?
  - What's the overall narrative structure?

### People-First Onboarding Flow

#### Step 1: People Selection
- **Prompt**: "Who do you want to create a story with?"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Helper Text**: "Start with the most important person, you can add more later"

#### Step 2: Relationship Context Gathering
**Step 2a: How Do You Know Each Other?**
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Options**: Work colleague, School/college friend, Family member, Neighbor, Online friend, Other
- **Follow-up**: "Tell me more about how you met"

**Step 2b: When Did You First Meet?**
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Options**: Recent (last year), Few years ago, College/school days, Childhood, Can't remember exactly
- **Context**: Helps determine relationship depth and memory accessibility

**Step 2c: Relationship Description**
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Options**: Close friends, Casual friends, Work buddies, Family, Acquaintances, Romantic partners
- **Purpose**: Influences story depth and emotional content

**Step 2d: Common Activities**
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Options**: Social activities, Work/professional, Sports/exercise, Travel/adventures, Creative projects, Just hang out casually
- **Purpose**: Provides context for memory categories

**Step 2e: Defining Contexts**
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Options**: College/fraternity/sorority, Workplace/office, Neighborhood/community, Online/gaming, Sports team, Hobby group, Family gatherings
- **Purpose**: Adds cultural and situational nuance

#### Step 3: AI-Powered Event Discovery
- **Input**: Relationship context from Step 2
- **Output**: Tailored memory categories with specific event suggestions
- **Examples**:
  - **College Friends**: "Drinking Stories", "College Adventures", "Frat House Memories"
  - **Work Colleagues**: "Work Adventures", "Team Building", "Career Moments"
  - **Childhood Friends**: "Growing Up Together", "Milestone Moments", "Life Changes"

#### Step 4: Event Selection
- **Prompt**: "Which of these moments would you like to capture?"
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Display**: AI-generated categories with specific events
- **Option**: "None of these - I have something else in mind"
- **Custom Input**: Free-form event description

#### Step 5: Continue with Foundation Building
- **Flow**: Same as Event-First Flow, starting from Step 3

### Prompt-First Onboarding Flow

#### Step 1: Prompt Selection
- **Prompt**: "Not sure where to begin? Choose a story type that resonates with you"
- **Categories**:
  - **Celebrations**: "Birthday parties, graduations, weddings"
  - **Adventures**: "Trips, road trips, getting lost"
  - **Milestones**: "First jobs, moving, major life changes"
  - **Everyday Magic**: "Ordinary moments that became extraordinary"
  - **Challenges**: "Times you overcame something together"
  - **Random**: "Surprise me with a creative prompt"

#### Step 2: Prompt Customization
- **Input**: Voice recording with real-time transcription
- **Recording Limit**: 5 minutes maximum
- **Visual Feedback**: Instagram-style circular progress ring around stop button
- **Display**: Selected prompt with specific examples
- **Customization**: Allow user to modify or add context
- **Examples**: "Birthday parties" → "My 30th birthday surprise party"

#### Step 3: Continue with People Selection
- **Flow**: Same as Event-First Flow, starting from Step 2

## Authentication and Invitation System

### Social Authentication
- **Login Options**: Google Sign-In and Apple Sign-In
- **When Required**: Before generating share URL (story creator) and before accessing shared story (invited users)
- **Data Collection**: Minimal data (name, email, profile picture)
- **User Experience**: Seamless integration with story flow

### Secure Invitation URLs
- **URL Structure**: `/invite/{code}` where code is 16+ character cryptographically secure random string
- **Security Features**: 
  - Unguessable codes (cryptographically secure generation)
  - Brute force protection through code length
  - Rate limiting on URL access attempts
  - One-time use per user (prevent multiple joins)
- **URL Management**:
  - Generated after foundation steps completion
  - Stored securely with expiration timestamp
  - 15-day expiration from generation date
  - Can be regenerated by story creator if needed

### Friend Onboarding Flow
1. **URL Access**: Friend clicks secure invitation URL
2. **Validation**: System validates code and expiration
3. **Story Preview**: Shows story context and current progress
4. **Social Login**: Required to join the story
5. **Join Experience**: Brief onboarding and immediate access to collaborative steps

## Audio Recording Interface (Registration Phase)

### Recording Flow
1. **Record Button**: Large, prominent button with microphone icon
2. **Recording State**: Button changes to stop icon, Instagram-style circular progress ring fills around button
3. **Visual Feedback**: Circular ring progressively fills over 5 minutes, showing recording progress
4. **Stop Button**: Same button, different icon and color
5. **Transcription**: Text appears in editable text area after stopping
6. **Editing**: Standard text input with character count
7. **Continue**: "Next" button to proceed to next step

### Recording Limits
- **Maximum Duration**: 5 minutes per question
- **Visual Countdown**: Instagram-style circular progress ring around stop button
- **Auto-stop**: Automatic stop at 5 minutes with confirmation
- **User Control**: Option to stop early if finished

### User Experience
- **Clear Messaging**: "You have up to 5 minutes to share your story"
- **Visual Progress**: Circular ring shows recording progress
- **Standard Navigation**: Click "Next" button to continue after editing transcription

## Success Metrics

### Registration Metrics
- **Entry Point Distribution**: Which path do users choose most?
- **Foundation Completion Rate**: How many users complete the initial 3 steps?
- **Social Login Conversion**: How many users complete social login?
- **Time to Foundation**: How long does it take to complete foundation steps?
- **Drop-off Points**: Where do users abandon the registration flow?

### Invitation Metrics
- **URL Generation Rate**: How many users generate invitation URLs?
- **URL Sharing Rate**: How often do users share story URLs?
- **Invitation Acceptance**: What percentage of invites are accepted?
- **Time to Join**: How long between URL generation and friend joining?
- **URL Expiration Rate**: How many URLs expire before being used?

### Business Metrics
- **Time to First Complete Story**: How long until users experience the full value?
- **Network Effects**: Average number of friends invited per story
- **Retention**: 7-day, 30-day, and 90-day retention rates
- **User Acquisition Cost**: Cost per acquired user through invitations

## User Experience Principles

### 1. Progressive Disclosure
- Start simple, add complexity as users engage
- Don't overwhelm with all 12 steps at once
- Break complex tasks into digestible chunks

### 2. Immediate Feedback
- Show AI analysis in real-time
- Provide clear progress indicators
- Give users confidence they're on the right track

### 3. Clear Value Proposition
- Always show the transformation from scattered memories to cohesive story
- Demonstrate the magic of AI synthesis
- Highlight the collaborative nature of the experience

### 4. Mobile-First Design
- All interactions must work seamlessly on mobile
- Optimize for touch interactions
- Voice input for story details

### 5. Audio-First Experience
- Voice recording as primary input method
- Real-time transcription with editing capabilities
- Visual feedback for recording progress
- Familiar button-based navigation

## Error Handling and Edge Cases

### Audio Recording Issues
- **Recording Failure**: "Recording failed. Please try again."
- **Transcription Errors**: "Transcription unclear. Please re-record or edit text."
- **Network Issues**: "Connection lost. Your recording is saved locally."

### URL Access Issues
- **Expired URL**: "This invitation has expired. Please ask for a new link."
- **Invalid URL**: "Invalid invitation link. Please check the URL."
- **Already Joined**: "You've already joined this story."
- **Rate Limited**: "Too many attempts. Please try again later."

### Authentication Issues
- **Login Failure**: "Unable to sign in. Please try again or use a different method."
- **Account Creation**: "Creating your account... Please wait."
- **Data Sync**: "Syncing your data... This may take a moment."

## Future Enhancements

### 1. Voice-Guided Onboarding
- Audio prompts for each step
- Voice-to-text for story details
- Conversational interface

### 2. Relationship Intelligence
- Store relationship contexts for future stories
- Track relationship evolution over time
- Suggest reconnecting with people you haven't created stories with recently

### 3. Smart Invitation Targeting
- AI-suggested friends based on story context
- Personalized invitation messages
- Optimal timing for invitation sends

### 4. Progressive Profile Building
- Collect user preferences during onboarding
- Build relationship graph over time
- Personalized story suggestions

## Conclusion

The registration and onboarding flow is the critical first touchpoint that determines whether users will experience the full value of collaborative storytelling. By understanding user intent through multiple entry points and guiding them through foundation building, we create the foundation for successful story creation and collaboration.

The key to success is making the initial experience feel natural and engaging while building toward that magical moment when users realize they can transform their scattered memories into something beautiful and meaningful with their friends.
