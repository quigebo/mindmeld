require 'rails_helper'

RSpec.describe Theming::ImageProviderService, type: :service do
  let(:service) { described_class.new }
  let(:entity) { create(:entity, name: 'Paris', entity_type: 'place') }

  describe '#fetch_background_image' do
    context 'when API key is not configured' do
      before do
        allow(Rails.application.credentials).to receive(:unsplash).and_return(nil)
      end

      it 'returns default image URL' do
        expect(service.fetch_background_image(entity)).to eq(described_class::DEFAULT_IMAGE_URL)
      end
    end

    context 'when API key is configured' do
      before do
        allow(Rails.application.credentials).to receive(:unsplash).and_return(
          double('unsplash_credentials', access_key: 'test_key')
        )
      end

      context 'when API call succeeds' do
        let(:mock_response) do
          {
            'results' => [
              {
                'urls' => {
                  'regular' => 'https://example.com/image.jpg',
                  'full' => 'https://example.com/image-full.jpg'
                }
              }
            ]
          }
        end

        before do
          allow(service).to receive(:make_api_request).and_return(mock_response)
        end

        it 'returns the image URL from the API response' do
          expect(service.fetch_background_image(entity)).to eq('https://example.com/image.jpg')
        end

        it 'builds appropriate search query for place entities' do
          expect(service).to receive(:make_api_request).with(
            hash_including(
              query: /Paris/,
              orientation: 'landscape',
              per_page: 1
            )
          )

          service.fetch_background_image(entity)
        end

        it 'accepts additional options' do
          expect(service).to receive(:make_api_request).with(
            hash_including(
              orientation: 'portrait',
              per_page: 5
            )
          )

          service.fetch_background_image(entity, orientation: 'portrait', limit: 5)
        end
      end

      context 'when API call fails' do
        before do
          allow(service).to receive(:make_api_request).and_return(nil)
        end

        it 'returns default image URL' do
          expect(service.fetch_background_image(entity)).to eq(described_class::DEFAULT_IMAGE_URL)
        end
      end

      context 'when API raises an error' do
        before do
          allow(service).to receive(:make_api_request).and_raise(StandardError.new('API Error'))
        end

        it 'returns default image URL' do
          expect(service.fetch_background_image(entity)).to eq(described_class::DEFAULT_IMAGE_URL)
        end
      end
    end
  end

  describe '#fetch_secondary_images' do
    let(:entities) { [create(:entity, name: 'Paris'), create(:entity, name: 'London')] }

    before do
      allow(Rails.application.credentials).to receive(:unsplash).and_return(
        double('unsplash_credentials', access_key: 'test_key')
      )
    end

    it 'fetches images for multiple entities' do
      allow(service).to receive(:fetch_background_image).and_return('https://example.com/image.jpg')

      result = service.fetch_secondary_images(entities)
      expect(result).to eq(['https://example.com/image.jpg', 'https://example.com/image.jpg'])
    end

    it 'respects the limit parameter' do
      allow(service).to receive(:fetch_background_image).and_return('https://example.com/image.jpg')

      result = service.fetch_secondary_images(entities, 1)
      expect(result.length).to eq(1)
    end
  end

  describe 'search query building' do
    before do
      allow(Rails.application.credentials).to receive(:unsplash).and_return(
        double('unsplash_credentials', access_key: 'test_key')
      )
    end

    it 'adds category terms for place entities' do
      place_entity = create(:entity, name: 'Paris', entity_type: 'place')

      expect(service.send(:build_search_query, place_entity, {})).to match(/Paris (landscape|cityscape|architecture|travel)/)
    end

    it 'adds category terms for thing entities' do
      thing_entity = create(:entity, name: 'Eiffel Tower', entity_type: 'thing')

      expect(service.send(:build_search_query, thing_entity, {})).to match(/Eiffel Tower (object|still-life|abstract)/)
    end

    it 'adds additional terms when provided' do
      expect(service.send(:build_search_query, entity, additional_terms: 'sunset')).to match(/Paris.*sunset/)
    end
  end
end
