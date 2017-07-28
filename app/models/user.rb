class User < ApplicationRecord
	has_many :api_keys
	has_secure_password

	def is_admin?
		role == 'admin'
	end
end
