module Api
  module V1
    class AdvertisementsController < ApplicationController
      def index
        ads = Advertisement.running.ordered
        # Best-effort impression count — each ad returned to the app counts
        # as one view. Wrapped so a counter failure never breaks the banner.
        begin
          Advertisement.where(id: ads.map(&:id)).update_all("view_count = view_count + 1")
        rescue => e
          Rails.logger.error("[Advertisements] Failed to record views: #{e.message}")
        end

        render json: {
          success: true,
          data: ads.map { |a|
            {
              id:        a.id,
              title:     a.title,
              subtitle:  a.subtitle.presence,
              image_url: a.image.presence,
              link_url:  a.link_url.presence
            }
          }
        }
      end

      def click
        ad = Advertisement.find(params[:id])
        ad.increment!(:click_count)
        render json: { success: true }
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: "ບໍ່ພົບໂຄສະນາ" }, status: :not_found
      end
    end
  end
end
