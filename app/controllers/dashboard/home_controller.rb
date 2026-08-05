class Dashboard::HomeController < Dashboard::BaseController
  def index
    @total_users     = User.count
    @total_vehicles  = Vehicle.count
    @total_insurances = Insurance.count
    @total_inspections = Inspection.count
    @recent_vehicles = Vehicle.order(created_at: :desc).limit(5)
    @recent_users    = User.order(created_at: :desc).limit(5)
  end
end
