require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe ManifestsController do

  # This should return the minimal set of attributes required to create a valid
  # Manifest. As you add validations to Manifest, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { :label => "MyString",
                             :description => "Description string",
                             :manifest_json => { "@id" => "http://127.0.0.1:5000/manifest/1"},
                             :manifest_uri =>   "http://127.0.0.1:5000/manifest/1",
                             _id: 1
                         }}
  let(:post_attributes)  { { :label => "MyString",
                             :description => "Description string",
                             :manifest_json => { "@id" => "http://127.0.0.1:5000/manifest/2"},
                             :manifest_uri =>  "http://127.0.0.1:5000/manifest/2",
                             _id: 2
  }}

  before(:all) do
    @user = FactoryGirl.create(:manifest_admin_user)
  end

  before(:each) do
    sign_in @user
    @manifest = FactoryGirl.create(:manifest)
  end

  after(:each) do
    Manifest.each do |manifest|
      manifest.delete
    end
    sign_out @user
  end

  after(:all) do
    @user.delete
  end

  describe "GET index" do
    it "assigns all manifests as @manifests" do
      get :index
      assigns(:manifests).to_a.should eq(@manifest.to_a)
    end
  end

  describe "GET show" do
    it "assigns the requested manifest as @manifest" do
      get :show, {:id => @manifest.to_param}
      assigns(:manifest).should eq(@manifest)
    end
  end

  describe "GET new" do
    it "assigns a new manifest as @manifest" do
      get :new, {}
      assigns(:manifest).should be_a_new(Manifest)
    end
  end

  describe "GET edit" do
    it "assigns the requested manifest as @manifest" do
      get :edit, {:id => @manifest.to_param}
      assigns(:manifest).should eq(@manifest)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Manifest" do
        expect {
          post :create, {:manifest => post_attributes}
        }.to change(Manifest, :count).by(1)
      end

      it "assigns a newly created manifest as @manifest" do
        post :create, {:manifest => post_attributes}
        assigns(:manifest).should be_a(Manifest)
        assigns(:manifest).should be_persisted
      end

      it "redirects to the created manifest" do
        @manifest.delete  # concurrency issue?
        post :create, {:manifest => post_attributes}
        response.should redirect_to(Manifest.last)
      end
    end

    # describe "with invalid params" do
    #   it "assigns a newly created but unsaved manifest as @manifest" do
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     Manifest.any_instance.stub(:save).and_return(false)
    #     post :create, {:manifest => { "label" => "invalid value" }}
    #     assigns(:manifest).should be_a_new(Manifest)
    #   end
    #
    #   it "re-renders the 'new' template" do
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     Manifest.any_instance.stub(:save).and_return(false)
    #     post :create, {:manifest => { "label" => "invalid value" }}
    #     response.should render_template("new")
    #   end
    # end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested manifest" do
        manifest = Manifest.create! valid_attributes
        # Assuming there are no other manifests in the database, this
        # specifies that the Manifest created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Manifest.any_instance.should_receive(:update_attributes).with({ "label" => "MyString" })
        put :update, {:id => manifest.to_param, :manifest => { "label" => "MyString" }}
      end

      it "assigns the requested manifest as @manifest" do
        manifest = Manifest.create! valid_attributes
        put :update, {:id => manifest.to_param, :manifest => post_attributes}
        assigns(:manifest).should eq(manifest)
      end

      it "redirects to the manifest" do
        manifest = Manifest.create! valid_attributes
        put :update, {:id => manifest.to_param, :manifest => post_attributes}
        response.should redirect_to(manifest)
      end
    end

    describe "with invalid params" do
      it "assigns the manifest as @manifest" do
        manifest = Manifest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Manifest.any_instance.stub(:save).and_return(false)
        put :update, {:id => manifest.to_param, :manifest => { "manifest_json" => {} }}
        assigns(:manifest).should eq(manifest)
      end

      it "re-renders the 'edit' template" do
        manifest = Manifest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Manifest.any_instance.stub(:save).and_return(false)
        put :update, {:id => manifest.to_param, :manifest => { "manifest_json" => {}  }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested manifest" do
      manifest = Manifest.create! valid_attributes
      expect {
        delete :destroy, {:id => manifest.to_param}
      }.to change(Manifest, :count).by(-1)
    end

    it "redirects to the manifests list" do
      manifest = Manifest.create! valid_attributes
      delete :destroy, {:id => manifest.to_param}
      response.should redirect_to(manifests_path)
    end
  end

end
