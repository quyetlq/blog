# /api/auth
class V1::AuthAPI < Grape::API

  resource :auth do

    desc "Creates and returns access_token if valid login"
    params do
      requires :login, type: String, desc: "Username or email address"
      requires :password, type: String, desc: "Password"
    end
    post :login do
      if params[:login].include?("@")
        user = User.find_by_email(params[:login].downcase)
      else
        user = User.find_by_login(params[:login].downcase)
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
    post :new_mem do
      authenticate_admin!
      # check mem exists
      if !User.exists?(:email => params[:email])
        new_user = User.create! declared(params).to_h
      else
        new_user =  "User exists"
      end
      new_user
    end


    desc "Destroy member"
    params do
      requires :email, type: String
    end
    post :destroy_mem do
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
  end
end
