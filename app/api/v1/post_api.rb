class V1::PostApi < Grape::API
	resource :posts do
		
		desc "Create new post"
		params do
			requires :title, type: String
			requires :content, type: String
		end
		post :create do
			authenticate!
			slug = Post.create_slug_from_title params[:title].encode!("UTF-8")
			new_post = Post.create! declared(params).merge({user_id: current_user.id,
																											slug: slug}).to_h
		end

		desc "Detail post"
		params do
			requires :post_id, type: String
		end
		get ":post_id" do
			authenticate!
			post = Post.find_by_id(params[:post_id])
			post
		end
	end
end
