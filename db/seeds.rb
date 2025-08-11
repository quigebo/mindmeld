# Demo data for Storytime application

# Create users
alice = User.create!(name: "Alice Chen", email: "alice@example.com")
bob = User.create!(name: "Bob Smith", email: "bob@example.com")
charlie = User.create!(name: "Charlie Wilson", email: "charlie@example.com")

# Alice creates a story about their China trip
china_trip = Story.create!(
  title: "China Trip with Friends 2015",
  description: "Our amazing adventure through Beijing, Xi'an, and Hong Kong",
  creator: alice,
  start_date: Date.new(2015, 6, 15),
  end_date: Date.new(2015, 6, 30)
)

# Add participants
# The creator is automatically a participant
alice_participant = Participant.create!(
  user: alice,
  story: china_trip,
  status: "accepted",
  joined_at: Time.current
)

bob_participant = Participant.create!(
  user: bob,
  story: china_trip,
  status: "accepted",
  joined_at: Time.current
)

charlie_participant = Participant.create!(
  user: charlie,
  story: china_trip,
  status: "accepted",
  joined_at: Time.current
)

# Add some comments (memories and conversations)
# Using acts_as_commentable_with_threading
beijing_memory = Comment.build_from(
  china_trip,
  alice.id,
  "We landed in Beijing on June 15th and stayed at The Red Lantern Hostel in the hutongs. The traditional courtyard was beautiful!",
  "Beijing Arrival"
)
beijing_memory.location = "Beijing"
beijing_memory.occurred_at = DateTime.new(2015, 6, 15, 14, 0, 0)
beijing_memory.is_memory_worthy = true
beijing_memory.llm_analysis = {
  classification: "memory",
  confidence: 0.95,
  extracted_facts: ["arrival date", "accommodation name", "location type"]
}
beijing_memory.save!

food_memory = Comment.build_from(
  china_trip,
  bob.id,
  "Oh yes! And remember all the amazing street food we had that first night? Those lamb skewers from the night market were incredible.",
  "Street Food Experience"
)
food_memory.location = "Beijing"
food_memory.occurred_at = DateTime.new(2015, 6, 15, 20, 0, 0)
food_memory.is_memory_worthy = true
food_memory.llm_analysis = {
  classification: "memory",
  confidence: 0.88,
  extracted_facts: ["food experience", "specific dish", "time of day"]
}
food_memory.save!
food_memory.move_to_child_of(beijing_memory)

conversation = Comment.build_from(
  china_trip,
  charlie.id,
  "Haha yes! I think I ate about 20 of those skewers!"
)
conversation.is_memory_worthy = false
conversation.llm_analysis = {
  classification: "reaction",
  confidence: 0.92,
  reason: "Personal reaction without new factual information"
}
conversation.save!
conversation.move_to_child_of(food_memory)

wall_memory = Comment.build_from(
  china_trip,
  charlie.id,
  "The next day we hiked the Great Wall at Mutianyu section. It was less crowded than Badaling and the toboggan ride down was so much fun!",
  "Great Wall Adventure"
)
wall_memory.location = "Great Wall - Mutianyu"
wall_memory.occurred_at = DateTime.new(2015, 6, 16, 10, 0, 0)
wall_memory.is_memory_worthy = true
wall_memory.llm_analysis = {
  classification: "memory",
  confidence: 0.94,
  extracted_facts: ["activity", "specific location", "comparison", "unique experience"]
}
wall_memory.save!

# Create a synthesized memory
synthesized = SynthesizedMemory.create!(
  story: china_trip,
  content: "In June 2015, Alice, Bob, and Charlie embarked on an unforgettable journey through China. They landed in Beijing on June 15th and stayed at The Red Lantern Hostel, a traditional accommodation nestled in the historic hutongs with a beautiful courtyard. That first evening, they explored the local night market where Bob discovered the incredible lamb skewers that would become a highlight of their culinary adventures. The following day, the group hiked the Great Wall at the Mutianyu section, which Charlie noted was less crowded than the popular Badaling section. The experience was capped off with an exhilarating toboggan ride down the mountain.",
  metadata: {
    included_comment_ids: [beijing_memory.id, food_memory.id, wall_memory.id],
    generation_details: {
      model: "gpt-4",
      timestamp: Time.current,
      word_count: 95
    }
  }
)

puts "Demo data created successfully!"
puts "- #{User.count} users"
puts "- #{Story.count} story"
puts "- #{Participant.count} participants"
puts "- #{Comment.count} comments (#{Comment.memory_worthy.count} memory-worthy)"
puts "  - #{china_trip.comment_threads.count} root comment threads"
puts "- #{SynthesizedMemory.count} synthesized memory"
puts "- #{PaperTrail::Version.count} versions tracked"