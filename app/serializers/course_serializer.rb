class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :tutors
end
