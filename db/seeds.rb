# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a default user
user = User.find_or_create_by!(email: "user@example.com") do |u|
  u.name = "John Doe"
end

# Create some sample stories
stories = [
  {
    title: "Weekend Trip to the Mountains",
    description: "A beautiful weekend getaway with friends in the Rocky Mountains. We hiked, camped, and enjoyed the stunning views.",
    start_date: Date.current - 2.weeks,
    end_date: Date.current - 2.weeks + 3.days,
    creator: user
  },
  {
    title: "Birthday Celebration",
    description: "My 30th birthday party with family and close friends. We had a barbecue in the backyard and played games all evening.",
    start_date: Date.current - 1.month,
    end_date: Date.current - 1.month,
    creator: user
  },
  {
    title: "Beach Vacation",
    description: "A week-long vacation at the beach with my partner. We rented a small cottage and spent our days swimming, reading, and exploring the local area.",
    start_date: Date.current - 3.months,
    end_date: Date.current - 3.months + 7.days,
    creator: user
  }
]

stories.each do |story_attrs|
  story = Story.find_or_create_by!(title: story_attrs[:title], creator: story_attrs[:creator]) do |s|
    s.assign_attributes(story_attrs)
  end

  # Add some sample comments to each story
  comments = [
    {
      body: "The hike to the summit was incredible! The view from the top was absolutely breathtaking.",
      location: "Rocky Mountain National Park",
      occurred_at: story.start_date + 1.day,
      user: user
    },
    {
      body: "We saw a family of deer on our way down. The kids were so excited!",
      location: "Trail near Bear Lake",
      occurred_at: story.start_date + 1.day + 2.hours,
      user: user
    },
    {
      body: "The campfire that evening was perfect. We roasted marshmallows and told stories.",
      location: "Campsite",
      occurred_at: story.start_date + 1.day + 8.hours,
      user: user
    }
  ]

  comments.each do |comment_attrs|
    Comment.find_or_create_by!(body: comment_attrs[:body], commentable: story, user: comment_attrs[:user]) do |c|
      c.assign_attributes(comment_attrs)
    end
  end
end

puts "Seed data created successfully!"
puts "Created #{User.count} users"
puts "Created #{Story.count} stories"
puts "Created #{Comment.count} comments"