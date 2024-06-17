module Api
  module V1
    class CoursesController < ApplicationController
      def index
        begin
          page_number = params.dig(:page, :number) || 1
          page_size = params.dig(:page, :size) || 30
          @courses = Course.includes(:tutors)
                           .paginate(
                              page: page_number,
                              per_page: page_size
                            )

          render json: @courses, include: :tutors
        rescue => error
          render nothing: true, status: :bad_request
        end
      end

      def create
        @course = Course.new(course_params)
        if @course.save
          render json: @course.as_json, status: :created
        else
          render_error(@course, :unprocessable_entity)
        end
      end

      private
      def course_params
        params.require(:course).permit(
          :title,
          :description,
          tutors_attributes: [:first_name, :last_name, :email]
        )
      end
    end
  end
end
