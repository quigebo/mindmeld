namespace :llm do
  desc "Analyze all pending comments"
  task analyze_pending_comments: :environment do
    pending_comments = Comment.where(is_memory_worthy: nil)
    
    puts "Found #{pending_comments.count} pending comments to analyze..."
    
    pending_comments.find_each.with_index do |comment, index|
      puts "Analyzing comment #{index + 1}/#{pending_comments.count} (ID: #{comment.id})"
      CommentAnalysisJob.perform_later(comment.id)
    end
    
    puts "Queued #{pending_comments.count} comments for analysis"
  end

  desc "Regenerate all synthesized memories"
  task regenerate_all_memories: :environment do
    stories_with_memories = Story.joins(:comments).where(comments: { is_memory_worthy: true }).distinct
    
    puts "Found #{stories_with_memories.count} stories with memory-worthy comments..."
    
    stories_with_memories.find_each.with_index do |story, index|
      puts "Regenerating memory for story #{index + 1}/#{stories_with_memories.count} (ID: #{story.id})"
      MemorySynthesisJob.perform_later(story.id)
    end
    
    puts "Queued #{stories_with_memories.count} stories for memory regeneration"
  end

  desc "Show LLM processing statistics"
  task stats: :environment do
    total_comments = Comment.count
    analyzed_comments = Comment.where.not(is_memory_worthy: nil).count
    memory_worthy_comments = Comment.memory_worthy.count
    pending_analysis = total_comments - analyzed_comments
    total_stories = Story.count
    stories_with_synthesis = SynthesizedMemory.count
    
    puts "=== LLM Processing Statistics ==="
    puts "Total Comments: #{total_comments}"
    puts "Analyzed Comments: #{analyzed_comments}"
    puts "Memory-Worthy Comments: #{memory_worthy_comments}"
    puts "Pending Analysis: #{pending_analysis}"
    puts "Total Stories: #{total_stories}"
    puts "Stories with Synthesis: #{stories_with_synthesis}"
    puts "Analysis Rate: #{(analyzed_comments.to_f / total_comments * 100).round(2)}%"
    puts "Memory Rate: #{(memory_worthy_comments.to_f / analyzed_comments * 100).round(2)}%" if analyzed_comments > 0
  end

  desc "Test LLM configuration"
  task test_config: :environment do
    puts "Testing LLM configuration..."
    
    begin
      chat = RubyLLM.chat
      response = chat.ask("Hello! This is a test message to verify LLM configuration.")
      puts "✅ LLM configuration is working!"
      puts "Response: #{response.content[0..100]}..."
    rescue => e
      puts "❌ LLM configuration error: #{e.message}"
      puts "Please check your API keys and configuration in config/initializers/ruby_llm.rb"
    end
  end
end
