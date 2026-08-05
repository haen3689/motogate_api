class ApiController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    token = request.headers["Authorization"]&.split(" ")&.last
    raise "No token" unless token
    payload = JwtService.decode(token)
    @current_user = User.find(payload[:user_id])
  rescue => e
    render json: { error: e.message }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def render_success(data, status: :ok)
    render json: { success: true, data: data }, status: status
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { success: false, error: message }, status: status
  end
end
