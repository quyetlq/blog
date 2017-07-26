class API < Grape::API
  include BaseAPI

  # before do
  #   set_locale!
  # end

  mount API::V1
end