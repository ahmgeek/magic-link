require "magic_link/version"
require "magic_link/magician"

class MagicLink
  # Magician is a tiny wrapper around "Encrypt"
  include Magician

  class MagicLinkError < StandardError; end

  attr_accessor :token

  def initialize(email, user_auth_token, token = nil)
    @email            = email.to_s
    @auth_token  = user_auth_token.to_s
    @token            = token.to_s if token
  end

  # Generates only one magic-link for the user.
  def generate_token
    return unless token.nil?
    token = @auth_token
    temp_token = (token + '|' + Time.now.to_s) if token.index('|').nil?
    @token = Magician.encrypt temp_token
  end

  def expired?
    (expire_date + 1440.minutes) < Time.current
  end

  def expire_date
    token_splitter[:time]
  end

  def verify_authenticity
    unless user_auth_token == auth_token
      raise MagicLinkError, 'Token verfication failed!'
    end
    raise MagicLinkError, 'Token expired!' if expired?
    true
  end

  private

  # decrypt the magic link token.
  def magic_token
    Magician.decrypt token
  end

  def token_splitter
    token, time = magic_token.split('|')
    { token: token, time: Time.parse(time) }
  end

  def uset_auth_token
    token_splitter[:token]
  end
end
