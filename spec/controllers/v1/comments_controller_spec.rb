require 'rails_helper'

describe V1::CommentsController do
  before(:each) do
    request.accept = "application/json"
  end

  let(:temp_post) {FactoryGirl.create(:post)}
  let(:valid_comment_data) {{text: Faker::Lorem.sentence}}
  let(:invalid_comment_data) {{:non_comment_attribute => "no data"}}
  describe "GET #index" do
    it "doesn't get any comments if there is none" do
      get :index, {:post_id => temp_post.id}
      expect(assigns(:comments)).to eq([])
    end

    it "assigns all comments as @comments" do
      comment = FactoryGirl.create(:comment)
      get :index, {:post_id => comment.post.id}
      expect(assigns(:comments)).to eq([comment])
    end
  end

  describe "GET #show" do
    it "assigns the requested comment as @comment" do
      comment = FactoryGirl.create(:comment)
      get :show, {:id => comment.id, :post_id => comment.post.id}
      expect(assigns(:comment)).to eq(comment)
    end
  end

  describe "POST #create" do
    context "authenticated session" do
      before(:each) do
        user = FactoryGirl.create(:user)
        request.headers.merge!(user.create_new_auth_token)
      end
      context "with valid params" do

        it "creates a new Comment" do
          expect {
            post :create, {:post_id => temp_post.id, :comment => valid_comment_data}, format: :json
          }.to change(Comment, :count).by(1)
        end

        it "assigns a newly created comment as @comment" do
          req = post :create, format: :json, :comment => valid_comment_data, :post_id => temp_post.id
          expect(assigns(:comment)).to be_a(Comment)
          expect(assigns(:comment)).to be_persisted
          p = Post.find(temp_post.id)
          expect(p.comments_count).to eq(1)
        end

        it "respond with created response code" do
          post :create, format: :json, :post_id => temp_post.id, :comment => valid_comment_data
          expect(response).to have_http_status(:created)
        end
      end

      context "with invalid params" do
        it "doesn't create a comment if it has no body" do
          post :create, format: :json, :post_id => temp_post.id, :comment => invalid_comment_data
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "unauthenticated session" do
      it "respond with unauthenticated if no user session is present" do
        post :create, format: :json, :post_id => temp_post.id, :comment => valid_comment_data
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT #update" do
    context "authenticated session" do
      context "with valid params" do
        let(:new_attributes) {
          {:text => "updated comment"}
        }

        it "updates the requested comment" do
          comment = FactoryGirl.create(:comment)
          request.headers.merge!(comment.user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
          comment.reload
          expect(comment.text).to eq("updated comment")
        end

        it "assigns the requested comment as @comment" do
          comment = FactoryGirl.create(:comment)
          request.headers.merge!(comment.user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
          expect(assigns(:comment)).to eq(comment)
        end

        it "respond with success response code" do
          comment = FactoryGirl.create(:comment)
          request.headers.merge!(comment.user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
          expect(response).to have_http_status(:ok)
        end

        it "only comment owner can update his comment" do
          comment = FactoryGirl.create(:comment)
          random_user = FactoryGirl.create(:user)
          request.headers.merge!(random_user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
          expect(response).to have_http_status(:unauthorized)
        end

        it "admin user can update any comment" do
          comment = FactoryGirl.create(:comment)
          admin_user = FactoryGirl.create(:admin_user)
          request.headers.merge!(admin_user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
          expect(response).to have_http_status(:ok)
        end
      end

      context "with invalid params" do
        let(:invalid_new_attributes) {
          {:text => ""}
        }
        it "doesn't update a comment if it has no body" do
          comment = FactoryGirl.create(:comment)
          request.headers.merge!(comment.user.create_new_auth_token)
          put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => invalid_new_attributes
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "unauthenticated session" do
      let(:new_attributes) {
        {:body => "updated comment"}
      }
      it "respond with unauthenticated if no user session is present" do
        comment = FactoryGirl.create(:comment)
        put :update, format: :json, :post_id => temp_post.id, :id => comment.id, :comment => new_attributes
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "authenticated session" do
      it "destroys the requested comment" do
        comment = FactoryGirl.create(:comment)
        request.headers.merge!(comment.user.create_new_auth_token)
        expect {
          delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        }.to change(Comment, :count).by(-1)
      end

      it "return the no content status" do
        comment = FactoryGirl.create(:comment)
        request.headers.merge!(comment.user.create_new_auth_token)
        delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:no_content)
      end

      it "only comment owner can delete his comment" do
        comment = FactoryGirl.create(:comment)
        random_user = FactoryGirl.create(:user)
        request.headers.merge!(random_user.create_new_auth_token)
        delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:unauthorized)
      end

      it "admin user can update any comment" do
        comment = FactoryGirl.create(:comment)
        admin_user = FactoryGirl.create(:admin_user)
        request.headers.merge!(admin_user.create_new_auth_token)
        delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:no_content)
      end
    end

    context "unauthenticated session" do
      it "respond with unauthenticated if no user session is present" do
        comment = FactoryGirl.create(:comment)
        delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end


  describe "toggle like #toggle_like" do
    context "authenticated session" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        request.headers.merge!(@user.create_new_auth_token)
      end
      it "like a comment" do
        comment = FactoryGirl.create(:comment)
        get :toggle_like, {:post_id => comment.post.id, :id => comment.id}
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['likers_count']).to eq(1)
      end

      it "like return success status" do
        comment = FactoryGirl.create(:comment)
        get :toggle_like, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:ok)
      end

      it "unlike a comment" do
        comment = FactoryGirl.create(:comment)
        @user.like!(comment)
        get :toggle_like, {:post_id => comment.post.id, :id => comment.id}
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['likers_count']).to eq(0)
      end
    end

    context "unauthenticated session" do
      it "respond with unauthenticated if no user session is present" do
        comment = FactoryGirl.create(:comment)
        delete :destroy, {:post_id => comment.post.id, :id => comment.id}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
