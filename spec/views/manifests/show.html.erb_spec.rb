require 'spec_helper'

describe "manifests/show" do


  before(:each) do
    @manifest = assign(:manifest, stub_model(Manifest,
      :label => "Label",
      :description => "Description",
      :manifest_json => Hash.new
    ))
  end


  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Label/)
    rendered.should match(/Description/)
    rendered.should match(/Manifest json/)
  end
end
