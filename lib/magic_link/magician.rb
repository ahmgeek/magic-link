require 'encryptor'

module Magician
  class << self
    def encrypt(value)
      key   = opts[:key]
      iv    = opts[:iv]
      salt  = opts[:salt]
      Encryptor.encrypt(value: value, key: key, iv: iv, salt: salt)
    end

    def decrypt(value)
      Encryptor.decrypt(value: value, key: key, iv: iv, salt: salt)
    end

    private

    def opts(algorithm = 'aes-256-gcm')
      cipher = OpenSSL::Cipher.new(algorithm.to_s)
      cipher.encrypt
      secret_key = cipher.random_key
      iv = cipher.random_iv
      salt = SecureRandom.random_bytes(512)
      { key: secret_key, iv: iv, salt: salt }
    end
  end
end
