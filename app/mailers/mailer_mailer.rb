class MailerMailer < ApplicationMailer
	default from: ENV['gmail_username']

	def notification_user_follow(user)
		@user = user
		mail(to: @user.email, subject: "%s just follow you" % @user.user_name)
	end
end
