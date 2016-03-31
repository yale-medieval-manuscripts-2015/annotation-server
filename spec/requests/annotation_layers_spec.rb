require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "AnnotationLayers" do

  before(:all) do
    @user = FactoryGirl.create(:manifest_admin_user)
    @layer = FactoryGirl.create(:annotation_layer)
    @accessibleProject = FactoryGirl.create(:accessible_project)
    @accessibleList = FactoryGirl.create(:accessible_list)
  end

  before(:each) do
    login_as(@user, :scope => :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  after(:all) do
    @user.delete
    @annotation_layer.delete
    @accessibleProject.delete
    @accessibleList.delete
  end

  describe "GET /layers" do
    it "should have a layer" do
      get annotation_layers_path, {format: 'json'}
      expect(response).to be_success
      expect(json[0]['@id']).to eq(@layer['@id'])
    end
  end

  describe "GET /layer" do
    it "should return the desired layer" do
      get "/layer/#{@layer.id}", {format: 'json'}
      expect(response).to be_success
      expect(json['@id']).to eq(@layer['@id'])
    end
  end


end
