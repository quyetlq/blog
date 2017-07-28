class V1::UserAPI < Grape::API
	resource :users do

    desc "Creates and returns access_token if valid login"
    params do
      requires :login, type: String, desc: "Username or email address"
      requires :password, type: String, desc: "Password"
    end
    post :login do
    	puts "sdfadsafdasfas"
      if params[:login].include?("@")
        user = User.find_by_email(params[:login].downcase)
      else
        user = User.find_by_login(params[:login].downcase)
      end

      if user && user.authenticate(params[:password])
        key = ApiKey.create(user_id: user.id, expires_at: DateTime.now+30)
        {token: key.access_token}
      else
        error!('Unauthorized.', 401)
      end
    end

    desc "Returns pong if logged in correctly"
    # params do
      # requires :token, type: String, desc: "Access token."
    # end
    get :ping do
      authenticate!
      { message: "pong" }
    end

    desc "Logout and remove all access_token of user"
    post :logout do
    	authenticate!
      current_user.api_keys.find_by!(access_token: access_token_header).expire!
      {"message": "logout sucssess!"}
    end
  end
end