# Storytime: Collaborative Memory Sharing

A Ruby on Rails application where friends can collaboratively remember and document stories together.

## Overview

Storytime allows users to create shared stories (like "China Trip 2015") and invite friends to contribute their memories. All contributions are unified as comments, with an LLM determining which comments contain substantive memories. The system then synthesizes these memories into a cohesive narrative from a third-person perspective.

## Data Models

### User
Basic user model for authentication and identification.
- **Attributes**: name, email
- **Associations**: 
  - Has many created stories
  - Has many stories through participants
  - Has many comments

### Story
The main container for a collaborative memory (e.g., "China Trip with Friends 2015").
- **Attributes**: title, description, start_date, end_date
- **Associations**:
  - Belongs to creator (User)
  - Has many participants
  - Has many comments
  - Has one synthesized memory

### Participant
Join model between User and Story.
- **Attributes**: status (invited/accepted/declined), invited_at, joined_at
- **Validations**: Unique user per story
- **Key Methods**:
  - `accept!` - Accept invitation and set joined_at
  - `decline!` - Decline invitation
  - `can_contribute?` - Check if user can add comments (accepted participants only)

### Comment
Powered by `acts_as_commentable_with_threading` gem for hierarchical comments.
- **Attributes**: 
  - body (text content)
  - subject (optional title)
  - is_memory_worthy (boolean) - determined by LLM
  - llm_analysis (JSON) - stores LLM reasoning
  - location (optional)
  - occurred_at (when the memory happened)
- **Features**:
  - Nested set structure for efficient threading
  - Polymorphic association to any commentable model
  - Built-in threading with `move_to_child_of` method
- **Scopes**:
  - `memory_worthy` - Comments flagged as memories
  - `chronological` - Ordered by when events occurred

### SynthesizedMemory
AI-generated narrative with versioning via `paper_trail` gem.
- **Attributes**: 
  - content (the synthesized story)
  - metadata (JSON) - includes comment IDs used
  - generated_at
- **Features**:
  - Full version history with paper_trail
  - Can view and revert to previous versions
  - Tracks who made changes and when
- **Key Methods**:
  - `included_comment_ids` - Which comments were used
  - `versions` - Access version history
  - `previous_version` - Get previous version

## Key Features

1. **Natural Conversation Flow**: Users simply add comments without worrying about categorization
2. **LLM Integration**: Background jobs analyze comments to determine memory-worthiness
3. **Threaded Comments**: Powered by `acts_as_commentable_with_threading` for efficient nested discussions
4. **Version Control**: `paper_trail` tracks all changes to synthesized memories
5. **Temporal Flexibility**: Comments track when they were posted vs. when events occurred
6. **Simple Access Control**: All accepted participants can contribute equally

## Database Indexes

- Unique index on participants (user_id, story_id)
- Index on participants.status for filtering
- Index on comments.is_memory_worthy for memory queries
- Index on comments.occurred_at for chronological ordering

## Technical Stack

- **Ruby on Rails 8.0**
- **acts_as_commentable_with_threading** - Hierarchical comment system
- **paper_trail** - Model versioning and audit trail
- **PostgreSQL** - Database (configured for SQLite in development)

## Usage Examples

### Creating a Comment
```ruby
comment = Comment.build_from(story, user.id, "Remember that amazing sunset?", "Sunset Memory")
comment.is_memory_worthy = true
comment.save!
```

### Threading Comments
```ruby
reply = Comment.build_from(story, another_user.id, "Yes! It was beautiful!")
reply.save!
reply.move_to_child_of(comment)
```

### Accessing Version History
```ruby
memory = story.synthesized_memory
memory.versions                    # All versions
memory.paper_trail.previous_version # Previous version
```

## Next Steps

1. Add authentication (Devise)
2. Create controllers and views
3. Implement LLM integration with RubyLLM
4. Add background job processing (Sidekiq)
5. Build UI with Hotwire and Tailwind CSS
6. Add media attachments support
7. Implement notification system