# MindMeld: Collaborative Memory Sharing

MindMeld allows users to create shared stories (like "China Trip 2015") and invite friends to contribute their memories. All contributions are unified as comments, with an LLM determining which comments are most relevant and synthesizing them into a cohesive narrative.

## Features

- **Collaborative Storytelling**: Invite friends to contribute their memories to shared stories
- **AI-Powered Synthesis**: LLM automatically analyzes and synthesizes contributions into cohesive narratives
- **Memory Enhancement**: AI helps recover forgotten details and enhance story context
- **Family Legacy**: Preserve memories for future generations
- **Modern UI**: Beautiful, responsive interface built with Hotwire and Tailwind CSS

## Technology Stack

- **Backend**: Ruby on Rails 7.1
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Styling**: Tailwind CSS
- **Database**: PostgreSQL
- **AI Integration**: RubyLLM
- **Deployment**: Kamal

## Getting Started

1. Clone the repository
2. Install dependencies: `bundle install`
3. Setup database: `rails db:setup`
4. Start the server: `rails server`

## Development

- Run tests: `bundle exec rspec`
- Lint code: `bundle exec rubocop`
- Format code: `bundle exec standardrb --fix`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.