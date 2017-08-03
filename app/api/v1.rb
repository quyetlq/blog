class V1 < Grape::API
  version "v1", using: :path

  mount UserAPI
  # mount AuthAPI
  mount PostApi
  mount CommentAPI
  mount Admin::AdminAPI

  desc "Return the current API version - V1."
  get do
  	apis = []
  	API.routes.each do |route|
	    info = route.instance_variable_get :@options
	    description = "%-40s..." % info[:description][0..39]
	    method = "%-7s" % info[:method]
	    api = "#{description}  #{method}#{info[:path]} #{route.path}"
	    apis.push api
  	end
    {version: "v1",
    	apis: apis}
  end
end