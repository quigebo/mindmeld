require 'rails_helper'

# Load the concern manually since it's not autoloading properly
load 'app/models/concerns/llm_integration.rb'

RSpec.describe LLMIntegration, type: :model do
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include LLMIntegration
      
      attr_accessor :id
      
      def comments
        @comments ||= []
      end
      
      def synthesized_memory
        @synthesized_memory
      end
      
      def synthesized_memory=(memory)
        @synthesized_memory = memory
      end
    end
  end
  
  let(:instance) { test_class.new }

  describe '#has_pending_analysis?' do
    it 'returns true when there are comments without analysis' do
      allow(instance).to receive(:comments).and_return([
        double('comment', is_memory_worthy: nil),
        double('comment', is_memory_worthy: true)
      ])
      
      expect(instance.has_pending_analysis?).to be true
    end

    it 'returns false when all comments have been analyzed' do
      allow(instance).to receive(:comments).and_return([
        double('comment', is_memory_worthy: true),
        double('comment', is_memory_worthy: false)
      ])
      
      expect(instance.has_pending_analysis?).to be false
    end

    it 'returns false when there are no comments' do
      allow(instance).to receive(:comments).and_return([])
      
      expect(instance.has_pending_analysis?).to be false
    end
  end

  describe '#ready_for_synthesis?' do
    it 'returns true when there are memory-worthy comments' do
      allow(instance).to receive(:comments).and_return([
        double('comment', is_memory_worthy: true),
        double('comment', is_memory_worthy: false)
      ])
      
      expect(instance.ready_for_synthesis?).to be true
    end

    it 'returns false when there are no memory-worthy comments' do
      allow(instance).to receive(:comments).and_return([
        double('comment', is_memory_worthy: false),
        double('comment', is_memory_worthy: nil)
      ])
      
      expect(instance.ready_for_synthesis?).to be false
    end

    it 'returns false when there are no comments' do
      allow(instance).to receive(:comments).and_return([])
      
      expect(instance.ready_for_synthesis?).to be false
    end
  end

  describe '#latest_synthesized_memory_with_metadata' do
    it 'returns nil when no synthesized memory exists' do
      instance.synthesized_memory = nil
      
      expect(instance.latest_synthesized_memory_with_metadata).to be_nil
    end

    it 'returns metadata when synthesized memory exists' do
      memory = double('memory',
        content: 'Test content',
        metadata: {
          'title' => 'Test Title',
          'summary' => 'Test Summary',
          'themes' => ['theme1', 'theme2'],
          'key_moments' => ['moment1'],
          'generation_details' => {
            'total_memories' => 5,
            'model_used' => 'gpt-4'
          }
        },
        generated_at: Time.current,
        versions: double('versions', count: 2)
      )
      
      instance.synthesized_memory = memory
      result = instance.latest_synthesized_memory_with_metadata
      
      expect(result).to include(
        content: 'Test content',
        title: 'Test Title',
        summary: 'Test Summary',
        themes: ['theme1', 'theme2'],
        key_moments: ['moment1'],
        generated_at: memory.generated_at,
        total_memories: 5,
        model_used: 'gpt-4',
        version_count: 2
      )
    end

    it 'handles missing metadata gracefully' do
      memory = double('memory',
        content: 'Test content',
        metadata: nil,
        generated_at: Time.current,
        versions: double('versions', count: 0)
      )
      
      instance.synthesized_memory = memory
      result = instance.latest_synthesized_memory_with_metadata
      
      expect(result).to include(
        content: 'Test content',
        title: nil,
        summary: nil,
        themes: [],
        key_moments: [],
        generated_at: memory.generated_at,
        total_memories: nil,
        model_used: nil,
        version_count: 0
      )
    end
  end

  describe 'placeholder methods' do
    it 'raises NotImplementedError for llm_service' do
      expect { instance.llm_service }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end

    it 'raises NotImplementedError for regenerate_synthesis!' do
      expect { instance.regenerate_synthesis! }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end

    it 'raises NotImplementedError for reanalyze_all_comments!' do
      expect { instance.reanalyze_all_comments! }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end

    it 'raises NotImplementedError for llm_stats' do
      expect { instance.llm_stats }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end

    it 'raises NotImplementedError for memory_types_distribution' do
      expect { instance.memory_types_distribution }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end

    it 'raises NotImplementedError for memory_contributors' do
      expect { instance.memory_contributors }.to raise_error(NotImplementedError, 'LLM services not yet available')
    end
  end
end
