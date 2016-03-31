require 'spec_helper'

describe "annotation_layers/edit" do
  before(:each) do
    @annotation_layer = assign(:annotation_layer, stub_model(AnnotationLayer,
      :@id => "MyString",
      :label => "MyString",
      :motivation => "MyString",
      :description => "MyText",
      :attribution => "MyText",
      :license => "MyString"
    ))
  end

  it "renders the edit annotation_layer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", annotation_layer_path(@annotation_layer), "post" do
      #assert_select "input#annotation_layer_@id[name=?]", "annotation_layer[@id]"
      assert_select "input#annotation_layer_label[name=?]", "annotation_layer[label]"
      assert_select "input#annotation_layer_motivation[name=?]", "annotation_layer[motivation]"
      assert_select "textarea#annotation_layer_description[name=?]", "annotation_layer[description]"
      assert_select "input#annotation_layer_attribution[name=?]", "annotation_layer[attribution]"
      assert_select "input#annotation_layer_license[name=?]", "annotation_layer[license]"
    end
  end
end
