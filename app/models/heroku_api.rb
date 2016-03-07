# Small wrapper around api calls to Heroku api
class HerokuApi
  def initialize(token)
    @token = token
  end

  def user_information
    get("/account")
  end

  def recent_releases_for(application)
    get_range("/apps/#{application}/releases", "version; order=desc,max=10;")
  end

  def token_refresh(refresh_token)
    client = Faraday.new(url: "https://id.heroku.com")
    params = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_secret: ENV["HEROKU_OAUTH_SECRET"]
    }
    response = client.post "/oauth/token", params

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  attr_reader :token

  def get(path)
    response = client.get do |request|
      request.url path
      request.headers["Accept"] = "application/vnd.heroku+json; version=3"
      request.headers["Accept-Encoding"] = ""
      request.headers["Content-Type"]    = "application/json"
      request.headers["Authorization"]   = "Bearer #{token}"
    end

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  def get_range(path, range)
    response = client.get do |request|
      request.url path
      request.headers["Accept"] = "application/vnd.heroku+json; version=3"
      request.headers["Accept-Encoding"] = ""
      request.headers["Content-Type"]    = "application/json"
      request.headers["Authorization"]   = "Bearer #{token}"
      request.headers["Range"]           = range
    end

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  def post(path, body)
    response = client.post do |request|
      request.url path
      request.headers["Accept"] = "application/vnd.heroku+json; version=3"
      request.headers["Accept-Encoding"] = ""
      request.headers["Content-Type"]    = "application/json"
      if token
        request.headers["Authorization"] = "Bearer #{token}"
      end
      request.body = body.to_json
    end

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  private

  def client
    @client ||= Faraday.new(url: "https://api.heroku.com")
  end
end
