require "rails_helper"

RSpec.describe Api::V1::CoursesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v1/courses").to route_to("api/v1/courses#index")
    end

    it "routes to #create" do
      expect(post: "/api/v1/courses").to route_to("api/v1/courses#create")
    end
  end
end
