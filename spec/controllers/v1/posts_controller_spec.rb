require 'rails_helper'

describe V1::PostsController do
  before(:each) do
    request.accept = "application/json"
  end

  let(:valid_session) { {} }
  let(:valid_post_data) {{body: Faker::Lorem.sentence}}
  let(:invalid_post_data) {{:non_post_attribute => "no data"}}
  describe "GET #index" do
    it "doesn't get any posts if there is none" do
      get :index, {}, valid_session
      expect(assigns(:posts)).to eq([])
    end

    it "assigns all posts as @posts" do
      post = FactoryGirl.create(:post)
      get :index, {}, valid_session
      expect(assigns(:posts)).to eq([post])
    end
  end

  describe "GET #show" do
    it "assigns the requested post as @post" do
      post = FactoryGirl.create(:post)
      get :show, {:id => post.to_param}, valid_session
      expect(assigns(:post)).to eq(post)
    end
  end

  describe "POST #create" do
    context "authenticated session" do
      before(:each) do
        user = FactoryGirl.create(:user)
        request.headers.merge!(user.create_new_auth_token)
      end
      context "with valid params" do

        it "creates a new Post" do
          expect {
            post :create, format: :json, :post => valid_post_data
          }.to change(Post, :count).by(1)
        end

        it "assigns a newly created post as @post" do
          post :create, format: :json, :post => valid_post_data
          expect(assigns(:post)).to be_a(Post)
          expect(assigns(:post)).to be_persisted
        end

        it "respond with created response code" do
          post :create, format: :json, :post => valid_post_data
          expect(response).to have_http_status(:created)
        end
      end

      context "with invalid params" do
        it "doesn't create a post if it has no body" do
          post :create, format: :json, :post => invalid_post_data
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "unauthenticated session" do
      it "respond with unauthenticated if no user session is present" do
        post :create, format: :json, :post => valid_post_data
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT #update" do
    context "authenticated session" do
      before(:each) do
        user = FactoryGirl.create(:user)
        request.headers.merge!(user.create_new_auth_token)
      end
      context "with valid params" do
        let(:new_attributes) {
          {:body => "updated post"}
        }

        it "updates the requested post" do
          post = FactoryGirl.create(:post)
          put :update, format: :json, :id => post.id, :post => new_attributes
          post.reload
          expect(post.body).to eq("updated post")
        end

        it "assigns the requested post as @post" do
          post = FactoryGirl.create(:post)
          put :update, format: :json, :id => post.id, :post => new_attributes
          expect(assigns(:post)).to eq(post)
        end

        it "respond with success response code" do
          post = FactoryGirl.create(:post)
          put :update, format: :json, :id => post.id, :post => new_attributes
          expect(response).to have_http_status(:ok)
        end
      end

      context "with invalid params" do
        let(:invalid_new_attributes) {
          {:body => ""}
        }
        it "doesn't update a post if it has no body" do
          post = FactoryGirl.create(:post)
          put :update, format: :json, :id => post.id, :post => invalid_new_attributes
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "unauthenticated session" do
      let(:new_attributes) {
        {:body => "updated post"}
      }
      it "respond with unauthenticated if no user session is present" do
        post = FactoryGirl.create(:post)
        put :update, format: :json, :id => post.id, :post => new_attributes
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "authenticated session" do
      before(:each) do
        user = FactoryGirl.create(:user)
        request.headers.merge!(user.create_new_auth_token)
      end
      it "destroys the requested post" do
        post = FactoryGirl.create(:post)
        expect {
          delete :destroy, {:id => post.id}, valid_session
        }.to change(Post, :count).by(-1)
      end

      it "return the no content status" do
        post = FactoryGirl.create(:post)
        delete :destroy, {:id => post.id}, valid_session
        expect(response).to have_http_status(:no_content)
      end

      it "cascade the delete to the children comments of a deleted post" do
        comment = FactoryGirl.create(:comment)
        expect {
          delete :destroy, {:id => comment.post.id}, valid_session
        }.to change(Comment, :count).by(-1)
      end
    end

    context "unauthenticated session" do
      it "respond with unauthenticated if no user session is present" do
        post = FactoryGirl.create(:post)
        delete :destroy, {:id => post.id}, valid_session
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
