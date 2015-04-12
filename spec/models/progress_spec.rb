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

      it 'allows to save if the new progress total for the objective is less than the target goal' do
        objective = create(:objective, targetgoal: 100)
        progress = build(:progress, amount: 99, objective: objective)
        expect(progress.save).to eq true       
      end

      it 'does not allow to save if the new progress total for the objective will be greater than the target goal' do
        objective = create(:objective, targetgoal: 100)
        progress = build(:progress, amount: 101, objective: objective)
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

  describe 'scopes' do
    describe '#recent_progress' do
      before(:all) do
        Progress.delete_all
      end

      it 'returns an empty array when there are is no progress' do
        expect(described_class.recent_progress).to eq []
      end

      it 'returns all progress objects in an array in decending order of creation' do
        progress1 = create(:progress)
        progress2 = create(:progress)

        expect(described_class.recent_progress). to eq [progress2,progress1]
      end

    end
  end

  describe '#progress_history' do
    it 'returns an empty array if objective is not found' do
      objective = create(:objective)
      expect(described_class.progress_history(objective)).to eq []
    end

    it 'returns an array of hashes of all progress for a given objective' do
      objective = create(:objective)
      progress1 = create(:progress, amount: 10, objective: objective)
      progress2 = create(:progress, amount: 10, objective: objective)

      expect(described_class.progress_history(objective)).to eq [
        {id: progress2.id, amount: progress2.amount, created_at: progress2.created_at.to_s},
        {id: progress1.id, amount: progress1.amount, created_at: progress1.created_at.to_s}
      ]
    end
  end
end
