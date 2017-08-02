# encoding: utf-8
class Post < ApplicationRecord
  belongs_to :user

  scope :list_posts, ->(user_id){where("user_id = ?", "#{user_id}")}
  scope :newfeed, ->(user_id){where("user_id = ? AND created_at >= ?", "#{user_id}", Time.now - 7.days)}

  class << self
    def create_slug_from_title title
    	title = title.gsub(/Đ/, 'D')
    	title = title.gsub(/đ/, 'd')
      title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s.gsub(/(\W+)/, '-')
    end
  end
end
