module Api
  module V1
    class OnboardingSlidesController < ApplicationController
      def index
        slides = OnboardingSlide.active.ordered
        render json: {
          success: true,
          data: slides.map { |s|
            {
              title:     s.title,
              subtitle:  s.subtitle,
              image_url: s.image_url.presence
            }
          }
        }
      end
    end
  end
end
