require 'rails_helper'

RSpec.describe "Api::V1::EventsControllers", type: :request do
  describe "GET /api/v1/events" do
    pending "should return a json list of all events"
  end

  describe 'POST /api/v1/events' do
    it 'should create a new event' do
      p = attributes_for(:event)
      post '/api/v1/events', params: p
      expect(response).to be_successful
    end

    it 'should reject events with non-image file types' do
      p = attributes_for(:event, image: fixture_file_upload('txt/random/random.txt', 'text/plain'))
      post '/api/v1/events', params: p
      expect(response).to_not be_successful
    end
  end
end
