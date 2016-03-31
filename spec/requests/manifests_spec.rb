require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "Manifests" do
  before(:all) do
    @user = FactoryGirl.create(:manifest_admin_user)
  end

  after(:all) do
    @user.delete
  end

  before(:each) do
    login_as(@user, :scope => :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  describe "GET /manifests" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get manifests_path
      response.status.should be(200)
    end
  end
end
