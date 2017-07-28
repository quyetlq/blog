class ApiKey < ApplicationRecord
	# attr_accessible :access_token, :expires_at, :user_id, :active, :application
  before_create :generate_access_token
  before_create :set_expiration
  belongs_to :user

  validates :expires_at, presence: true

  def expired?
    DateTime.now >= self.expires_at
  end

  def expire!
    update_attributes! expires_at: Time.zone.now
  end

  private
  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def set_expiration
    self.expires_at = DateTime.now+30
  end

  def api_key_params
    params.require(:api_key).permit(:access_token, :expires_at, :user_id, :active, :application)
  end
end
