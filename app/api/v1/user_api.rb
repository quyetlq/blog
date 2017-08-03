class V1::UserAPI < Grape::API
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
      {
        token: key.access_token,
        user_name: user.user_name,
        role: user.role,
      }
    else
      error!('Unauthorized!', 401)
    end
  end

  resource :users do
    before do
      authenticate!
    end
    
    desc "Logout and remove all access_token of user"
    params do
      requires :token, type: String, desc: "Access token."
    end
    post :logout do
      # authenticate!
      current_user.api_keys.find_by!(access_token: params[:token]).expire!
      {"message": "logout sucssess!"}
    end

    desc "Show me"
    get do
      current_user
    end

    desc "Returns pong if logged in correctly"
    get :ping do
      { message: "pong" }
    end

    desc "Like post"
    params do
      requires :post_id, type: Integer
    end
    post :like do
      # authenticate!
      like = Like.create! declared(params).merge({user_id: current_user.id})
      {"msg": "You just like post"}
    end

    desc "Dislike post"
    params do
      requires :post_id, type: Integer
    end
    post :dislike do
      # authenticate!
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
      # authenticate!
      users = User.find_by(role: "member")
      users
    end

    desc "Follow user"
    params do
      requires :followed_id, type: Integer
    end
    post :follow do
      # authenticate!
      follow = Relationship.create! declared(params).merge({follower_id: current_user.id})
      if !follow.blank?
        user = User.find_by(id: params[:followed_id])
        MailerMailer.notification_user_follow(user).deliver_now
        puts "Just send email notification from #{user.email}"
      end
      follow
    end

    desc "Unfollow user"
    params do
      requires :followed_id, type: Integer
    end
    post :unfollow do
      # authenticate!
      follow = Relationship.find_by(followed_id: params[:followed_id], follower_id: current_user.id)
      if follow
        follow.destroy
        {"msg": "Unfollow sucssess!"}
      else
        {"msg": "Unfollow fail!"}
      end
    end

    desc "Get all post of user"
    params do
      requires :user_id, type: Integer
    end
    get ":user_id/posts" do
      # authenticate!
      posts = Post.list_posts params[:user_id]
      if !posts
        posts = []
      end
      {"posts": posts}
    end

    desc "Get all followed of user"
    params do
      requires :user_id, type: Integer
    end
    get ":user_id/following" do
      # authenticate!
      user = User.find_by(id: params[:user_id])
      {"users": user.following}
    end

    desc "Get all followed of user"
    params do
      requires :user_id, type: Integer
    end
    get ":user_id/followers" do
      # authenticate!
      user = User.find_by(id: params[:user_id])
      {"users": user.followers}
    end

    desc "Newfeed"
    # params do 
    #   requires :user_id, type: Integer
    # end
    get :newfeed do
      # authenticate!
      newfeeds = {:newfeed => []}
      following = current_user.following
      following.each do |user|
        posts = Post.newfeed user.id
        if !posts.blank?
          user = user.attributes
          user[:posts] = posts
          newfeeds[:newfeed].push(user)
        end
      end

      posts = Post.newfeed current_user.id
      if !posts.blank?
        user = current_user.attributes
        user[:posts] = posts
        newfeeds[:newfeed].push(user)
      end
      newfeeds
    end
  end
end
