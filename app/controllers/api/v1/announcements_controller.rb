module Api
  module V1
    class AnnouncementsController < ApiController
      skip_before_action :authenticate!, only: %i[index show]

      def index
        anns = Announcement.active.ordered
        render json: {
          success: true,
          data: anns.map { |a|
            {
              id:         a.id,
              title:      a.title,
              body:       a.body,
              image_url:  a.image.presence,
              created_at: a.created_at
            }
          }
        }
      end

      def show
        a = Announcement.active.find(params[:id])
        a.increment!(:view_count)
        render json: {
          success: true,
          data: {
            id:         a.id,
            title:      a.title,
            body:       a.body,
            image_url:  a.image.presence,
            created_at: a.created_at
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: "ບໍ່ພົບປະກາດ" }, status: :not_found
      end

      # Called when the app opens the ປະກາດ list — resets the bell badge by
      # marking every announcement up to now as seen for this user.
      def mark_seen
        current_user.update!(last_announcements_seen_at: Time.current)
        render_success({ ok: true })
      end
    end
  end
end
