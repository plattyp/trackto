require 'rails_helper'

RSpec.describe Progress, :type => :model do
  describe 'validation' do
    context 'amount' do
      it 'allows to save if amount is an integer' do
        progress = build(:progress)
        progress.amount = 100
        expect(progress.save).to eq true
      end
      
      it 'does not allow to save it progress is not an integer' do
        progress = build(:progress)
        progress.amount = "Andrew"
        expect(progress.save).to eq false
      end
    end
  end
end
