namespace :entities do
  desc "Extract entities from all comments in a story"
  task :extract_from_story, [:story_id] => :environment do |task, args|
    story_id = args[:story_id]
    
    unless story_id
      puts "Usage: rails entities:extract_from_story[story_id]"
      exit 1
    end

    story = Story.find(story_id)
    puts "Processing entities for story: #{story.title}"
    
    total_comments = story.comment_threads.count
    processed = 0
    
    story.comment_threads.find_each do |comment|
      begin
        puts "Processing comment #{comment.id}..."
        Llm::EntityExtractionService.new(comment).extract!
        processed += 1
        puts "✓ Processed comment #{comment.id}"
      rescue => e
        puts "✗ Failed to process comment #{comment.id}: #{e.message}"
      end
    end
    
    puts "\nCompleted! Processed #{processed}/#{total_comments} comments"
    
    # Show summary of extracted entities
    entities = Entity.grouped_by_type(story)
    puts "\nExtracted entities:"
    puts "People: #{entities[:people].count}"
    puts "Places: #{entities[:places].count}"
    puts "Things: #{entities[:things].count}"
  end

  desc "Extract entities from a single comment"
  task :extract_from_comment, [:comment_id] => :environment do |task, args|
    comment_id = args[:comment_id]
    
    unless comment_id
      puts "Usage: rails entities:extract_from_comment[comment_id]"
      exit 1
    end

    comment = Comment.find(comment_id)
    puts "Processing entities for comment: #{comment.body[0..100]}..."
    
    begin
      result = Llm::EntityExtractionService.new(comment).extract!
      puts "✓ Successfully extracted entities:"
      puts "  People: #{result[:people]}"
      puts "  Places: #{result[:places]}"
      puts "  Things: #{result[:things]}"
      puts "  Total: #{result[:total]}"
    rescue => e
      puts "✗ Failed to extract entities: #{e.message}"
    end
  end

  desc "Extract entities from all comments in all stories"
  task :extract_all => :environment do
    total_stories = Story.count
    total_comments = Comment.count
    processed_stories = 0
    processed_comments = 0
    
    puts "Processing entities for all stories and comments..."
    
    Story.find_each do |story|
      puts "\nProcessing story: #{story.title} (ID: #{story.id})"
      
      story.comment_threads.find_each do |comment|
        begin
          Llm::EntityExtractionService.new(comment).extract!
          processed_comments += 1
        rescue => e
          puts "  ✗ Failed to process comment #{comment.id}: #{e.message}"
        end
      end
      
      processed_stories += 1
      puts "  ✓ Completed story #{processed_stories}/#{total_stories}"
    end
    
    puts "\n🎉 Completed! Processed #{processed_comments} comments across #{processed_stories} stories"
  end

  desc "Show entity statistics for all stories"
  task :stats => :environment do
    puts "Entity Statistics:\n"
    
    Story.find_each do |story|
      entities = Entity.grouped_by_type(story)
      puts "#{story.title}:"
      puts "  People: #{entities[:people].count}"
      puts "  Places: #{entities[:places].count}"
      puts "  Things: #{entities[:things].count}"
      puts "  Total: #{entities[:people].count + entities[:places].count + entities[:things].count}"
      puts ""
    end
    
    total_entities = Entity.count
    puts "Overall totals:"
    puts "  Total entities: #{total_entities}"
    puts "  People: #{Entity.people.count}"
    puts "  Places: #{Entity.places.count}"
    puts "  Things: #{Entity.things.count}"
  end
end
