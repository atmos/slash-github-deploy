# Module for handling User's tokens. Encrypting/Decrypting etc
module TokenManagement
  extend ActiveSupport::Concern

  included do
  end

  # Things exposed to the included class as class methods
  module ClassMethods
    def fernet_secret
      ENV["FERNET_SECRET"] ||
        raise("No FERNET_SECRET environmental variable set")
    end
  end

  def decrypt_value(value)
    Fernet.verifier(self.class.fernet_secret, value).message
  rescue Fernet::Token::InvalidToken, NoMethodError
    nil
  end

  def encrypt_value(value)
    Fernet.generate(self.class.fernet_secret, value)
  end

  def reset_creds
    self.github_token = nil
    reset_heroku
    self.save
  end

  def github_token=(token)
    self[:enc_github_token] = encrypt_value(token)
  end

  def github_token
    decrypt_value(self[:enc_github_token])
  end

  def reset_heroku
    self.heroku_email = nil
    self.enc_heroku_token = nil
    self.enc_heroku_refresh_token = nil
    self.heroku_expires_at = nil
  end

  def heroku_configured?
    self[:enc_heroku_token] && !self[:enc_heroku_token].empty?
  end

  def heroku_refresh_token
    decrypt_value(self[:enc_heroku_refresh_token])
  end

  def heroku_refresh_token=(token)
    self[:enc_heroku_refresh_token] = encrypt_value(token)
  end

  def heroku_token=(token)
    self[:enc_heroku_token] = encrypt_value(token)
  end

  # This will refresh the heroku token if expired.
  def heroku_token
    unless heroku_refresh_token && heroku_expires_at
      reset_heroku
      save
      return nil
    end
    if heroku_expired?
      refresh_heroku
    end
    decrypt_value(self[:enc_heroku_token])
  end

  def heroku_expired?
    !heroku_expires_at || heroku_expires_at < Time.now.utc
  end

  def refresh_heroku
    body = HerokuApi.new(nil).token_refresh(heroku_refresh_token)
    if body && body["access_token"] && body["expires_in"]
      self.heroku_token = body["access_token"]
      expires_at = Time.at(Time.now.utc.to_i + body["expires_in"]).utc
      self.heroku_expires_at = expires_at
    else
      reset_heroku
    end
    self.save
  end
end
