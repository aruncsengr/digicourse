class Course < ApplicationRecord
  has_many :tutors, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  accepts_nested_attributes_for :tutors
end
