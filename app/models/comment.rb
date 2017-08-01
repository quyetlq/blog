class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  # belongs_to :comment, class_name: 'Comment', foreign_key: 'reply_comment_id'
  # validates :reply_comment, presence: true
end
