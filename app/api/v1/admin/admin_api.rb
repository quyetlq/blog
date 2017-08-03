class V1::Admin::AdminAPI < Grape::API
	before do
		authenticate_admin!
	end

	resource :admin do

		desc "Show profile"
		get do
			current_user
		end

		desc "All users"
    get :all_users do
      users = User.all
      {"users": users}
    end

		desc "Create new member"
    params do
      requires :user_name, type: String
      requires :email, type: String
      requires :password, type: String
    end
    post :create_mem do
      # check mem exists
      if !User.exists?(:email => params[:email])
        new_user = User.create! declared(params).merge({role: "member"}).to_h
      else
        new_user =  "User exists"
      end
      new_user
    end


    desc "Destroy member"
    params do
      requires :email, type: String
    end
    delete :destroy_mem do
      # check mem exists
      if User.exists?(:email => params[:email])
        User.find_by(:email => params[:email]).destroy
        res = "Delete success!"
      else
        res = "User not exists"
      end
      res
    end

    desc "Statistic user"
    params do
    	requires :user_id, type: Integer
    end
    get ":user_id/statistics" do
    	res = {}
    	user = User.find(params[:user_id])
    	res[:user] = user
    	res[:posts_num] = user.posts.length
    	res[:follower_num] = user.following.length
    	res
    end
	end
end
