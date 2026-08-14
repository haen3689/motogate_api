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

    # The short-lived token behind the public /verify/:token QR is minted with
    # scope "verify" precisely so it can't act as a session if it leaks — and
    # it leaks by design, since it's displayed on screen as a QR and travels
    # in a plain URL. That scope was never actually checked here, so anyone
    # who photographed the QR could call the full authenticated API as its
    # owner (read ID/licence PII, edit the profile, delete vehicles) for as
    # long as the token lived. Only VerificationsController accepts it.
    raise "Token not valid for this API" if payload[:scope].to_s == "verify"

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
