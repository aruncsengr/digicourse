require 'rails_helper'

RSpec.describe Tutor, type: :model do
  it { should belong_to(:course) }

  describe 'validations uniqueness' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:email) }

    context 'uniqueness' do
      subject { build(:tutor) }
      it { should validate_uniqueness_of(:email) }
    end
  end
end
