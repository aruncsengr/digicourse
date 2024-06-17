require 'rails_helper'

RSpec.describe Course, type: :model do
  it { should have_many(:tutors) }

  describe 'validations uniqueness' do
    it { should validate_presence_of(:title) }

    context 'uniqueness' do
      subject { build(:course) }
      it { should validate_uniqueness_of(:title) }
    end
  end
end
