module ApplicationCable
  # /cable had no identification of any kind: no `identified_by`, no
  # `find_verified_user`, no `reject_unauthorized_connection`. The only thing
  # in front of it was ActionCable's same-origin check, which any non-browser
  # client defeats by sending the right Origin header. Combined with the global
  # "user_updates" stream — which carried id_number, license_number,
  # date_of_birth and signed URLs to ID-card and licence photos for every user
  # who edited their profile — an anonymous WebSocket client could sit and
  # collect the identity documents of the entire user base.
  #
  # Two kinds of client legitimately connect here:
  #   - the mobile app, authenticating with the same JWT it uses for the REST
  #     API, passed as ?token= on the cable URL (WebSocket clients cannot set
  #     an Authorization header)
  #   - ActiveAdmin pages in a browser, which already carry a Devise session
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_admin

    def connect
      self.current_admin = find_admin
      self.current_user = find_user

      reject_unauthorized_connection unless current_admin || current_user
    end

    private

    def find_admin
      env["warden"]&.user(:admin_user)
    rescue StandardError
      nil
    end

    def find_user
      token = request.params[:token]
      return nil if token.blank?

      payload = JwtService.decode(token)
      # The QR verify token is deliberately short-lived and public-facing; it
      # must not open a realtime session any more than it may call the REST API.
      return nil if payload[:scope].to_s == "verify"

      User.find_by(id: payload[:user_id])
    rescue StandardError
      nil
    end
  end
end
