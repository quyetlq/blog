module BaseAPI
	extend ActiveSupport::Concern

  included do
    prefix "api"
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers
    # error_formatter :json
    default_format :json

    # rescue_from Grape::Exceptions::ValidationErrors do
    #   error!({error_code: "400",
    #           message: "ValidationErrors"}, 200)
    # end

    # rescue_from APIError::Base do |e|
    #   error_code = Settings.error_formatter.error_codes.public_send(
    #     e.class.name.split("::").drop(1).map(&:underscore).first)
    #   error!({error_code: error_code, message: e.message}, Settings.http_code.code_200)
    # end

    # rescue_from ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid,
    #   JSON::ParserError do |e|
    #   error!({error_code: Settings.error_formatter.error_codes.data_operation, message: e.message},
    #     Settings.http_code.code_200)
    # end

    # rescue_from ActiveRecord::RecordNotFound do
    #   error!({error_code: Settings.error_formatter.error_codes.record_not_found,
    #           message: "record_not_found"},
    #     Settings.http_code.code_200)
    # end

    helpers do
	   def authenticate!
        error!('Unauthorized. Invalid or expired token.', 401) unless current_user
      end

      def authenticate_admin!
        error!('Unauthorized. You are not admin.', 401) unless current_user.is_admin?
      end

      def current_user
        # find token. Check if valid.
        token = ApiKey.where(access_token: headers["Authorization"]).first
        if token && !token.expired?
          @current_user = User.find(token.user_id)
        else
          false
        end
      end
    end
  end
end
