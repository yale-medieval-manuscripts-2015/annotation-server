require 'spec_helper'

describe "manifests/edit" do

  before(:each) do
    @manifest = assign(:manifest, stub_model(Manifest,
      :label => "MyString",
      :description => "MyString",
      :manifest_json => {}
    ))
  end

  it "renders the edit manifest form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", manifest_path(@manifest), "post" do
      assert_select "input#manifest_label[name=?]", "manifest[label]"
      assert_select "input#manifest_description[name=?]", "manifest[description]"
      assert_select "textarea#manifest_manifest_json[name=?]", "manifest[manifest_json]"
    end
  end
end
