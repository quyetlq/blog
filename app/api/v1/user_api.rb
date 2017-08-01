class V1::UserAPI < Grape::API
	resource :users do

    desc "Creates and returns access_token if valid login"
    params do
      requires :email, type: String, desc: "Username or email address"
      requires :password, type: String, desc: "Password"
    end
    post :login do
      if params[:email].include?("@")
        user = User.find_by_email(params[:email].downcase)
      else
        user = User.find_by_login(params[:email].downcase)
      end

      if user && user.authenticate(params[:password])
        key = ApiKey.create(user_id: user.id, expires_at: DateTime.now+30*60)
        {token: key.access_token}
      else
        error!('Unauthorized.', 401)
      end
    end

    desc "Create new member"
    params do
      requires :user_name, type: String
      requires :email, type: String
      requires :password, type: String
    end
    post :create_mem do
      authenticate_admin!
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
      authenticate_admin!
      # check mem exists
      if User.exists?(:email => params[:email])
        User.find_by(:email => params[:email]).destroy
        res = "Delete success!"
      else
        res = "User not exists"
      end
      res
    end

    desc "Returns pong if logged in correctly"
    # params do
    #   requires :token, type: String, desc: "Access token."
    # end
    get :ping do
      @current = authenticate!
      puts @current
      { message: "pong" }
    end

    desc "Logout and remove all access_token of user"
    params do
      requires :token, type: String, desc: "Access token."
    end
    post :logout do
      authenticate!
      current_user.api_keys.find_by!(access_token: params[:token]).expire!
      {"message": "logout sucssess!"}
    end

    desc "Like post"
    params do
      requires :post_id, type: Integer
    end
    post :like do
      authenticate!
      like = Like.create! declared(params).merge({user_id: current_user.id})
      {"msg": "You just like post"}
    end

    desc "Dislike post"
    params do
      requires :post_id, type: Integer
    end
    post :dislike do
      authenticate!
      like = Like.find_by(post_id: params[:post_id],
                          user_id: current_user.id)
      if like
        like.destroy
      else
        {"msg": "You not like post"}
      end
    end

    desc "All members"
    get :all_mem do
      authenticate!
      users = User.find_by(role: "member")
      users
    end

    desc "All users"
    get :all_users do
      authenticate_admin!
      users = User.all
      {"users": users}
    end

    desc "Follow user"
    params do
      requires :follower_id, type: Integer
    end
    post :follow do
      authenticate!
      follow = Relationship.create! declared(params).merge({followed_id: current_user.id})
      follow
    end
  end
end