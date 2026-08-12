class ApiController < ActionController::API
  include TransactionLogging

  before_action :authenticate!

  private

  def authenticate!
    # Falls back to a ?token= query param when there's no Authorization
    # header — needed for one-off links opened directly in an external
    # browser/PDF viewer (e.g. the insurance certificate), which can't
    # attach custom headers the way the app's own API client does.
    token = request.headers["Authorization"]&.split(" ")&.last || params[:token]
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
