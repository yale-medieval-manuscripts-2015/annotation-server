require 'spec_helper'

describe "annotation_layers/new" do
  before(:each) do
    assign(:annotation_layer, stub_model(AnnotationLayer,
      :@id => "MyString",
      :label => "MyString",
      :motivation => "MyString",
      :description => "MyText",
      :attribution => "MyText",
      :license => "MyString"
    ).as_new_record)
  end

  it "renders new annotation_layer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", annotation_layers_path, "post" do
      #assert_select "input[name=annotation_layer[@id]]", "annotation_layer[@id]"
      assert_select "input#annotation_layer_label[name=?]", "annotation_layer[label]"
      assert_select "input#annotation_layer_motivation[name=?]", "annotation_layer[motivation]"
      assert_select "textarea#annotation_layer_description[name=?]", "annotation_layer[description]"
      assert_select "input#annotation_layer_attribution[name=?]", "annotation_layer[attribution]"
      assert_select "input#annotation_layer_license[name=?]", "annotation_layer[license]"
    end
  end
end
