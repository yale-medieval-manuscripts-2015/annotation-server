require 'spec_helper'

describe "Welcome" do

  before(:all) do
    @user = FactoryGirl.create(:accessible_project_user)
    @accessibleProject = FactoryGirl.create(:accessible_project)
    @inaccessibleProject = FactoryGirl.create(:inaccessible_project)
  end

  after(:all) do
    @user.delete
    @accessibleProject.delete
    @inaccessibleProject.delete
  end

  before(:each) do
    login_as(@user, :scope => :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  describe "Home page" do

    it "Should have a projects list" do
       visit root_path
       expect(page).to have_content('Projects')
    end

    it "Should have an activity list" do
      visit root_path
      expect(page).to have_content('Activity')
    end

    it "Should have project that the user has permission to view" do
      visit root_path
      expect(page).to have_content(@accessibleProject.name)
    end

    it "Should not contain project that the user does not have permission to view" do
      visit root_path
      expect(page).to_not have_content(@inaccessibleProject.name)
    end

  end
end
