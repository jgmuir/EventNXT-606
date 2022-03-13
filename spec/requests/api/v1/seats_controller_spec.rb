require 'rails_helper'

RSpec.describe "Api::V1::SeatsController", type: :request do
  let!(:event) { create :event }
  let!(:seats) { create_list :seat, 3, category: 'test', event: event }

  describe "GET /api/v1/events/:event_id/seats" do
    it "gets all seats under the event" do
      get "/api/v1/events/#{event.id}/seats"
      expect(response).to be_successful
      expect(response.content_type).to eq("application/json; charset=utf-8")

      resb = JSON.parse response.body
      expect(resb.length).to be == 3
      expect(resb[0]).to include("category", "price")
    end

    it "gets paginated set of seats under the event" do
      get "/api/v1/events/#{event.id}/seats", params: {offset: 0, limit: 2}
      expect(response).to be_successful
      expect(response.content_type).to eq("application/json; charset=utf-8")

      resb = JSON.parse response.body
      expect(resb.length).to be == 2
      expect(resb[0, 1]).to match(seats[0, 1].map {|s| s.attributes})

      get "/api/v1/events/#{event.id}/seats", params: {offset: 2, limit: 2}
      resb = JSON.parse response.body
      expect(resb[0]).to match(seats[2].attributes)
    end
  end

  describe "GET /api/v1/events/:event_id/seats/:id" do
    it "returns a success response" do
      get "/api/v1/events/#{event.id}/seats/#{seats[0].id}"
      expect(response).to be_successful
      expect(response.content_type).to eq("application/json; charset=utf-8")

      resb = JSON.parse response.body
      expect(resb).to include("category", "price")
    end
  end

  describe "POST /api/v1/events/:event_id/seats" do
    it "creates a new Seat" do
      p = attributes_for :seat, id: nil, event_id: event.id
      prior_count = Seat.count

      post "/api/v1/events/#{event.id}/seats", params: {seats: p}
      expect(response).to be_successful
      expect(Seat.count).to eq prior_count+1
    end

    it "fails with invalid category" do
      p = attributes_for :seat, id: nil, event_id: event.id, category: nil

      post "/api/v1/events/#{event.id}/seats", params: {seats: p}
      expect(response).to_not be_successful
    end
  end

  describe "PATCH /api/v1/events/:event_id/seats/:id" do
    it "updates the requested seat" do
      p = attributes_for :seat, id: nil, category: "updated"
      patch "/api/v1/events/#{event.id}/seats/#{seats[0].id}", params: p
      expect(response).to be_successful

      seats[0].reload
      expect(seats[0].category).to eq "updated"
    end
  end

  describe "DELETE /api/v1/events/:event_id/seats/:id" do
    it "destroys the requested seat" do
      expect {
        delete "/api/v1/events/#{event.id}/seats/#{seats[0].id}"
      }.to change { Seat.count }.by(-1)
    end
  end
end
