require 'spec_helper'

describe Formbuilder::FormsController do

  TEST_JSON = '[{"label":"Please enter your clearance number","field_type":"text","required":true,"field_options":{},"cid":"c6"},{"label":"Security personnel #82?","field_type":"radio","required":true,"field_options":{"options":[{"label":"Yes","checked":false},{"label":"No","checked":false}],"include_other_option":true},"cid":"c10"},{"label":"Medical history","field_type":"file","required":true,"field_options":{},"cid":"c14"}]'

  let(:form) { FactoryGirl.create(:form) }

  describe '#update' do
    it 'should add new fields' do
      form.response_fields.count.should == 0
      put :update, id: form.id, fields: JSON.parse(TEST_JSON)
      form.response_fields.count.should == 3
      JSON::parse(response.body)[0]['label'].should == 'Please enter your clearance number'
      JSON::parse(response.body)[0]['field_type'].should == 'text'
      JSON::parse(response.body)[0]['cid'].should == 'c6'
      form.response_fields.first.class.should == Formbuilder::ResponseFieldText
    end

    it 'should remove existing fields' do
      form = FactoryGirl.create(:kitchen_sink_form)
      form.response_fields.count.should == 15
      put :update, id: form.id, fields: JSON.parse(TEST_JSON)
      form.reload.response_fields.count.should == 3
    end

    it 'should preserve existing fields' do
      form = FactoryGirl.create(:kitchen_sink_form)
      form.response_fields.count.should == 15
      json_payload = JSON.parse(TEST_JSON)
      json_payload[0]['id'] = form.response_fields.first.id
      put :update, id: form.id, fields: json_payload
      form.reload.response_fields.count.should == 3
      JSON::parse(response.body)[0]['id'].should == json_payload[0]['id']
      JSON::parse(response.body)[1]['cid'].should == 'c10'
      JSON::parse(response.body)[2]['cid'].should == 'c14'
    end

  end
end
