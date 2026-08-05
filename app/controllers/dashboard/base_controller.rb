class Dashboard::BaseController < ApplicationController
  layout 'dashboard'
  before_action :authenticate_admin_user!

  def current_admin
    current_admin_user
  end
  helper_method :current_admin
end
