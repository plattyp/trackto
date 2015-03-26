require 'rails_helper'

RSpec.describe Progress, :type => :model do
  describe 'validation' do
    context 'amount' do
      it 'allows to save if amount is an integer' do
        progress = build(:progress)
        progress.amount = 100
        expect(progress.save).to eq true
      end
      
      it 'does not allow to save if amount is not an integer' do
        progress = build(:progress)
        progress.amount = "Andrew"
        expect(progress.save).to eq false
      end

      context 'objective' do
        before(:all) do
          Objective.delete_all
        end

        it 'does not allow to save if it is not related to an objective' do
          progress = build(:progress)
          progress.objective_id = 0
          expect(progress.save).to eq false
        end
      end
    end
  end

  describe '#progress_history_for_objective' do
    it 'returns an empty array if objective is not found' do
    end

    it 'returns an array of hashes of all progress for a given objective' do
    end
  end
end
