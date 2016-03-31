require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe AnnotationLayersController do

  before(:all) do
    @user = FactoryGirl.create(:manifest_admin_user)
  end

  before(:each) do
    sign_in @user
  end

  after(:each) do
    sign_out @user
    AnnotationLayer.each do |layer|
      layer.delete
    end
  end

  after(:all) do
    @user.delete
  end

  # This should return the minimal set of attributes required to create a valid
  # AnnotationLayer. As you add validations to AnnotationLayer, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { :@id => "http://127.0.0.1:5000/layer/1234", label: "Test layer" } }

  describe "GET index" do
    it "assigns all annotation_layers as @annotation_layers" do
      annotation_layer = AnnotationLayer.create! valid_attributes
      get :index, {}
      assigns(:annotation_layers).to_a.should eq([annotation_layer])
    end
  end

  describe "GET show" do
    it "assigns the requested annotation_layer as @annotation_layer" do
      annotation_layer = AnnotationLayer.create! valid_attributes
      get :show, {:id => annotation_layer.to_param}
      assigns(:annotation_layer).should eq(annotation_layer)
    end
  end

  describe "GET new" do
    it "assigns a new annotation_layer as @annotation_layer" do
      get :new, {}
      assigns(:annotation_layer).should be_a_new(AnnotationLayer)
    end
  end

  describe "GET edit" do
    it "assigns the requested annotation_layer as @annotation_layer" do
      annotation_layer = AnnotationLayer.create! valid_attributes
      get :edit, {:id => annotation_layer.to_param}
      assigns(:annotation_layer).should eq(annotation_layer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AnnotationLayer" do
        expect {
          post :create, {:annotation_layer => valid_attributes}
        }.to change(AnnotationLayer, :count).by(1)
      end

      it "assigns a newly created annotation_layer as @annotation_layer" do
        post :create, {:annotation_layer => valid_attributes}
        assigns(:annotation_layer).should be_a(AnnotationLayer)
        assigns(:annotation_layer).should be_persisted
      end

      it "redirects to the created annotation_layer" do
        post :create, {:annotation_layer => valid_attributes}
        response.should redirect_to(AnnotationLayer.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved annotation_layer as @annotation_layer" do
        # Trigger the behavior that occurs when invalid params are submitted
        AnnotationLayer.any_instance.stub(:save).and_return(false)
        post :create, {:annotation_layer => { "@id" => "invalid value" }}
        assigns(:annotation_layer).should be_a_new(AnnotationLayer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        AnnotationLayer.any_instance.stub(:save).and_return(false)
        post :create, {:annotation_layer => { "@id" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested annotation_layer" do
        annotation_layer = AnnotationLayer.create! valid_attributes
        # Assuming there are no other annotation_layers in the database, this
        # specifies that the AnnotationLayer created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        AnnotationLayer.any_instance.should_receive(:update_attributes).with({ "@id" => "http://127.0.0.1:5000/layer/1234" })
        put :update, {:id => annotation_layer.to_param, :annotation_layer => { "@id" => "http://127.0.0.1:5000/layer/1234" }}
      end

      it "assigns the requested annotation_layer as @annotation_layer" do
        annotation_layer = AnnotationLayer.create! valid_attributes
        put :update, {:id => annotation_layer.to_param, :annotation_layer => valid_attributes}
        assigns(:annotation_layer).should eq(annotation_layer)
      end

      it "redirects to the annotation_layer" do
        annotation_layer = AnnotationLayer.create! valid_attributes
        put :update, {:id => annotation_layer.to_param, :annotation_layer => valid_attributes}
        response.should redirect_to(annotation_layer)
      end
    end

    describe "with invalid params" do
      it "assigns the annotation_layer as @annotation_layer" do
        annotation_layer = AnnotationLayer.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AnnotationLayer.any_instance.stub(:save).and_return(false)
        put :update, {:id => annotation_layer.to_param, :annotation_layer => { "@id" => "invalid value" }}
        assigns(:annotation_layer).should eq(annotation_layer)
      end

      it "re-renders the 'edit' template" do
        annotation_layer = AnnotationLayer.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AnnotationLayer.any_instance.stub(:save).and_return(false)
        put :update, {:id => annotation_layer.to_param, :annotation_layer => { "@id" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested annotation_layer" do
      annotation_layer = AnnotationLayer.create! valid_attributes
      expect {
        delete :destroy, {:id => annotation_layer.to_param}
      }.to change(AnnotationLayer, :count).by(-1)
    end

    it "redirects to the annotation_layers list" do
      annotation_layer = AnnotationLayer.create! valid_attributes
      delete :destroy, {:id => annotation_layer.to_param}
      response.should redirect_to(annotation_layers_path)
    end
  end

end
