class Post < ApplicationRecord
  belongs_to :user

  class << self
    def create_slug_from_title title
      title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s.gsub(/(\W+)/, '-')
    end
  end
end
