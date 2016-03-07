# Top-level class for all web endpoints
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def boomtown
    raise("Intentional exception from the web app")
  end
end
