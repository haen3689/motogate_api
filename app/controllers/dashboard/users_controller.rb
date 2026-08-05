class Dashboard::UsersController < Dashboard::BaseController
  def index
    @users = User.order(created_at: :desc)
    @users = @users.where("phone_number ILIKE ? OR first_name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    @total    = User.count
    @verified = User.where(verified: true).count
  end

  def show
    @user = User.includes(:vehicles).find(params[:id])
  end
end
