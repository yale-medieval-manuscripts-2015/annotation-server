require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe 'IIIF annotation lists' do

  before(:all) do
    @user = FactoryGirl.create(:accessible_project_user)
    @accessibleProject = FactoryGirl.create(:accessible_project)
    @inaccessibleProject = FactoryGirl.create(:inaccessible_project)
    @accessibleList = FactoryGirl.create(:accessible_list, "@id" => '"http://127.0.0.1:5000/list/accessible')
    @inaccessibleList = FactoryGirl.create(:inaccessible_list, "@id" => '"http://127.0.0.1:5000/list/inaccessible')
    @accessibleAnnotation = FactoryGirl.create(:annotation, annotationList: @accessibleList['@id'], 'permissions' => { 'read' => @accessibleProject.groups, 'write' => @user.personal_group })
    @inaccessibleAnnotation = FactoryGirl.create(:annotation, annotationList: @inaccessibleList['@id'], 'permissions' => { 'read' => @inaccessibleProject.groups, 'write' => [] })

  end

  before(:each) do
    login_as(@user, :scope => :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  after(:all) do
    @accessibleList.delete
    @inaccessibleList.delete
    @accessibleAnnotation.delete
    @inaccessibleAnnotation.delete
    @user.delete
    @accessibleProject.delete
    @inaccessibleProject.delete
  end

  describe 'List annotation lists' do

    it 'Should show list for accessible project' do
      get lists_path, {:canvas => @accessibleList.canvas}
      expect(response).to be_success
      expect(json.include?(@accessibleList['@id'])).to be_true
    end

    it 'Should not show list for inaccessible project' do
      get lists_path, {:canvas => @inaccessibleList.canvas}
      expect(response).to be_success
      expect(json.include?(@inaccessibleList['@id'])).to be_false
    end

  end

  describe 'List' do

    it "Should show an accessible annotation" do
      list_id = @accessibleList.id
      get "/list/#{list_id}"
      expect(response).to be_success
      expect(json['@id']).to eq(@accessibleList['@id'])
      expect(json['resources'].length).to eq(1)
      expect(json['resources'][0]['@id']).to eq(@accessibleAnnotation['@id'])
    end

    it "Should not show an inaccessible annotation" do
      list_id = @inaccessibleList.id
      get "/list/#{list_id}"
      expect(response).to be_success
      expect(json['@id']).to eq(@inaccessibleList['@id'])
      expect(json['resources'].length).to eq(0)
    end

  end

end