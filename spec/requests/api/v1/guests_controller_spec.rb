require 'rails_helper'

RSpec.describe "Api::V1::GuestsController", type: :request do
  describe "GET /api/v1/events/:event_id/guests/:guest_id" do
    context "there is an event" do
      let!(:event) { create :event }
      let!(:guest_list) { create_list :guest, 3, event: event }

      it 'should get a list of guests without :guest_id' do
        get "/api/v1/events/#{event.id}/guests"

        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")

        guests = JSON.parse response.body
        expect(guests.length).to be == 3
        expect(guests[0]).to include("email", "booked")
      end

      it 'should get a guest with :guest_id' do
        get "/api/v1/events/#{event.id}/guests/#{guest_list[0].id}"
        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")

        guest = JSON.parse response.body
        expect(guest["id"]).to eq(guest_list[0].id)
      end
    end
  end

  describe 'POST /api/v1/events/:event_id/guests' do
    context "event created by a user" do
      let!(:event) { create :event }
      it 'should create a new guest under the event by the user' do
        p = attributes_for(:guest, event_id: event.id, added_by: event.user.id)
        post "/api/v1/events/#{event.id}/guests", params: p
        expect(response).to be_successful, lambda { response.body; p }
      end
    end
  end

  describe 'GET /api/v1/events/:event_id/guests/:guest_id/invite' do 
    context 'there is a guest associated with an event' do
      let(:event) { create :event }
      let(:guest) { create :guest, event: event, booked: nil, invited_at: nil }

      it 'should update the time that the invitation was sent' do
        get "/api/v1/events/#{event.id}/guests/#{guest.id}/invite"
        expect(response).to be_successful

        g = Guest.find(guest.id)
        g.reload
        expect(g.invited_at).to_not eq nil
      end
    end
  end

  describe 'GET /api/v1/events/:event_id/guests/:guest_id/book' do
    context 'guest has received an invite to the event' do
      let(:event) { create :event }
      let(:guest) { create :guest, event: event, booked: nil }
      let(:seat) { create :seat, event: event }
      let(:ticket) { create :guest_seat_ticket, guest: guest, seat: seat }

      it 'should set the booking status true after accepting the confirmation' do
        patch "/api/v1/events/#{event.id}/guests/#{guest.id}/book", params: { accept: true, seats: {'0': {ticket_id: ticket.id, committed: 5}} }
        expect(response).to be_successful

        g = Guest.find(guest.id)
        expect(g.booked).to eq true
      end
    
      it 'should set the booking status to false after declining the confirmation' do
        patch "/api/v1/events/#{event.id}/guests/#{guest.id}/book", params: { }
        expect(response).to be_successful

        g = Guest.find(guest.id)
        expect(g.booked).to eq false
      end
    end
  end
end
