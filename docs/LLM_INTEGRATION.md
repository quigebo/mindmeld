# LLM Integration with RubyLLM

This document describes the LLM (Large Language Model) integration in Storytime, which uses [RubyLLM](https://github.com/crmne/ruby_llm) to automatically analyze comments and synthesize collaborative memories.

## Overview

The LLM integration provides two main features:

1. **Comment Analysis**: Automatically determines which comments contain substantive memories worth including in the final story
2. **Memory Synthesis**: Combines memory-worthy comments into a cohesive, third-person narrative

## Configuration

### Environment Variables

Set these environment variables in your `.env` file:

```bash
# Primary LLM provider (OpenAI)
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_ORGANIZATION_ID=your_org_id_here  # Optional

# Alternative providers
ANTHROPIC_API_KEY=your_anthropic_api_key_here  # Optional
GOOGLE_API_KEY=your_google_api_key_here        # Optional

# LLM settings
DEFAULT_LLM_MODEL=gpt-4o-mini
LLM_TIMEOUT=30
LLM_MAX_RETRIES=3
LLM_RETRY_DELAY=1
```

### Configuration File

The LLM configuration is in `config/initializers/ruby_llm.rb`. You can modify settings like:

- Default model
- Timeout settings
- Retry configuration
- Logging preferences

## How It Works

### 1. Comment Analysis

When a user creates a comment:

1. The comment is automatically queued for analysis via `CommentAnalysisJob`
2. The LLM analyzes the comment using structured output to determine:
   - Whether it contains a substantive memory
   - The type of memory (event, conversation, observation, feeling, etc.)
   - Key details mentioned
   - Confidence level in the analysis
3. The comment is marked as memory-worthy or not
4. If marked as memory-worthy, memory synthesis is triggered

### 2. Memory Synthesis

When memory-worthy comments are available:

1. The `MemorySynthesisJob` is triggered
2. The LLM synthesizes all memory-worthy comments into a cohesive narrative
3. The synthesis includes:
   - A compelling title
   - A flowing third-person narrative
   - Key themes and moments
   - Metadata about the synthesis process

## Service Classes

### LLM::CommentAnalyzerService

Analyzes individual comments to determine memory-worthiness.

```ruby
service = LLM::CommentAnalyzerService.new(comment)
service.analyze!
```

### LLM::MemorySynthesisService

Synthesizes memory-worthy comments into a narrative.

```ruby
service = LLM::MemorySynthesisService.new(story)
service.synthesize!
```

### LLM::StoryManagementService

Provides high-level management of LLM operations for a story.

```ruby
service = LLM::StoryManagementService.new(story)
service.regenerate_synthesis!
service.reanalyze_all_comments!
stats = service.processing_stats
```

## Background Jobs

### CommentAnalysisJob

Processes comment analysis asynchronously.

```ruby
CommentAnalysisJob.perform_later(comment.id)
```

### MemorySynthesisJob

Processes memory synthesis asynchronously.

```ruby
MemorySynthesisJob.perform_later(story.id)
```

## Model Integration

### Story Model

The `Story` model includes the `LLMIntegration` concern, providing methods like:

```ruby
story.regenerate_synthesis!
story.reanalyze_all_comments!
story.llm_stats
story.memory_types_distribution
story.memory_contributors
story.has_pending_analysis?
story.ready_for_synthesis?
story.latest_synthesized_memory_with_metadata
```

### Comment Model

Comments automatically trigger analysis on creation and provide methods for LLM results:

```ruby
comment.mark_as_memory_worthy!(analysis_data)
comment.mark_as_not_memory_worthy!(reason)
```

## Rake Tasks

### Analyze Pending Comments

```bash
rails llm:analyze_pending_comments
```

### Regenerate All Memories

```bash
rails llm:regenerate_all_memories
```

### Show Statistics

```bash
rails llm:stats
```

### Test Configuration

```bash
rails llm:test_config
```

## Usage Examples

### Manual Analysis

```ruby
# Analyze a specific comment
comment = story.comments.find(123)
LLM::CommentAnalyzerService.new(comment).analyze!

# Check analysis results
if comment.is_memory_worthy?
  puts "Memory type: #{comment.llm_analysis['memory_type']}"
  puts "Confidence: #{comment.llm_analysis['confidence']}"
end
```

### Manual Synthesis

```ruby
# Synthesize memories for a story
story = Story.find(456)
LLM::MemorySynthesisService.new(story).synthesize!

# Access synthesized memory
memory = story.synthesized_memory
puts memory.content
puts memory.metadata['title']
puts memory.metadata['themes']
```

### Story Management

```ruby
# Get processing statistics
stats = story.llm_stats
puts "Total comments: #{stats[:total_comments]}"
puts "Memory-worthy: #{stats[:memory_worthy_comments]}"
puts "Pending analysis: #{stats[:pending_analysis]}"

# Regenerate synthesis
story.regenerate_synthesis!

# Get memory contributors
contributors = story.memory_contributors
contributors.each { |c| puts "#{c[:name]} contributed memories" }
```

## Error Handling

The LLM integration includes comprehensive error handling:

- Failed analyses are logged with error details
- Comments with analysis errors are marked as not memory-worthy
- Background jobs include retry logic
- Configuration errors are caught and reported

## Performance Considerations

- All LLM operations are processed asynchronously via background jobs
- Comments are analyzed individually to avoid timeout issues
- Memory synthesis only runs when there are memory-worthy comments
- Results are cached in the database to avoid re-analysis

## Testing

Run the LLM integration tests:

```bash
rails test test/models/llm_integration_test.rb
```

Test the configuration:

```bash
rails llm:test_config
```

## Troubleshooting

### Common Issues

1. **API Key Errors**: Ensure your API keys are set correctly in environment variables
2. **Timeout Errors**: Increase `LLM_TIMEOUT` for longer operations
3. **Rate Limiting**: The system includes retry logic, but you may need to adjust retry settings
4. **Model Availability**: Ensure your chosen model is available with your API provider

### Debugging

Enable detailed logging in development:

```ruby
# In config/initializers/ruby_llm.rb
config.log_requests = true
config.log_responses = true
```

Check job status:

```bash
rails llm:stats
```

## Future Enhancements

Potential improvements to consider:

- Support for more LLM providers
- Custom analysis criteria per story
- Batch processing for large datasets
- Real-time streaming of analysis results
- Integration with external memory services
