class V1::CommentAPI < Grape::API
	resource :comments do
		desc "Create comment"
		params do
			requires :content, type: String
			requires :post_id, type: Integer
			requires :reply_comment_id, type: Integer
		end
		post :create do
			authenticate!
			new_comment = Comment.create! declared(params).merge({user_id: current_user.id}).to_h
			new_comment
		end

		desc "Destroy comment"
		params do
			requires :post_id, type: Integer
		end
		delete :destroy do
			authenticate!
			post = Post.find_by_id(params[:post_id])
			if post.user_id == current_user.id
				post.destroy
			else
				{"msg": "You have not permission!"}
			end
		end
	end
end