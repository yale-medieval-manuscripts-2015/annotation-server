require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "manifests/index" do


  before(:each) do

    assign(:manifests, [
      stub_model(Manifest,
        :label => "Label",
        :description => "Description",
        :manifest_json => Hash.new
      ),
      stub_model(Manifest,
        :label => "Label",
        :description => "Description",
        :manifest_json => Hash.new
      )
    ])
  end



  it "renders a list of manifests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    #assert_select "tr>td", :text => "Description".to_s, :count => 2

  end
end
