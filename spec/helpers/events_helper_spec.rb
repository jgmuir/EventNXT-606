require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Api::V1::EventHelper. For example:
#
# describe Api::V1::EventHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EventsController, type: :controller do
  describe 'showing homepage' do
      it 'should display the import form with the index template' do
    get :index
    expect(response).to render_template('index')
  end
end

describe 'showing the event details' do
    let(:event) {Event.create :id => 1, :title => 'fake_title', :date => 'fake_date', :box_office_customers => ''}
  it 'should display the correct basic event information with the show template' do
    Event.stub(:find).and_return(event)
    get :show, {:id => event.id}
    expect(assigns(:event)).to eq event
    expect(response).to render_template('show')
  end
  
  it 'should display all the correct guest details of the event with the show template' do
    guest_1 = Guest.create :id => 1, :event_id => event.id, :first_name => 'fake_first_name_1', :last_name => 'fake_last_name_1', :email_address => 'fake_email_address_1'
    guest_2 = Guest.create :id => 2, :event_id => event.id, :first_name => 'fake_first_name_2', :last_name => 'fake_last_name_2', :email_address => 'fake_email_address_2'
          guest_3 = Guest.create :id => 3, :event_id => event.id, :first_name => 'fake_first_name_3', :last_name => 'fake_last_name_3', :email_address => 'fake_email_address_3'
    event.stub(:guests).and_return([guest_1, guest_2, guest_3])
    get :show, {:id => event.id}
    expect(assigns(:guests)).to eq [guest_1, guest_2, guest_3]
    expect(response).to render_template('show')
  end
end

end
