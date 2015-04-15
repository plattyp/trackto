require_relative '../rails_helper'

RSpec.describe Objective, :type => :model do
  describe 'validation' do 
    context 'name' do
      it 'allows to save if name is greater than 0 character' do
        objective = build(:objective)
        objective.name = Faker::Lorem.characters(1)
        expect(objective.save).to eq true
      end
      it 'allows to save if name is less than 250 characters' do
        objective = build(:objective)
        objective.name = Faker::Lorem.characters(249)
        expect(objective.save).to eq true
      end

      it 'does not allow if targetdate less than today' do
        objective = build(:objective, targetdate: Time.now - 1.day)
        expect(objective.save).to eq false
      end

      it 'does not allow if targetgoal is equal to 0' do
        objective = build(:objective, targetgoal: 0)
        expect(objective.save).to eq false
      end

      it 'does not allow to save if name is 0 characters' do
        objective = build(:objective)
        objective.name = Faker::Lorem.characters(0)
        expect(objective.save).to eq false
      end

      it 'does not allow to save if name is greater than or equal to 250 characters' do
        objective = build(:objective)
        objective.name = Faker::Lorem.characters(251)
        expect(objective.save).to eq false
      end
    end
    context 'description' do
      it 'allows to save if description is less than or equal to 500 characters' do
        objective = build(:objective)
        objective.description = Faker::Lorem.characters(499)
        expect(objective.save).to eq true
      end
      it 'does not allow to save if description is greater than 500 characters' do
        objective = build(:objective)
        objective.description = Faker::Lorem.characters(501)
        expect(objective.save).to eq false
      end
    end
    context 'targetgoal' do
      it 'allows to save if targetgoal is an integer' do
        objective = build(:objective)
        objective.targetgoal = 1
        expect(objective.save).to eq true
      end

      it 'does not allow to save if targetgoal is not an integer' do
        objective = build(:objective)
        objective.targetgoal = "Andrew"
        expect(objective.save).to eq false
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      Objective.delete_all
      @objective1 = create(:objective)
      @objective2 = create(:objective)
      @objective3 = create(:objective)
    end

    describe 'all_objectives' do
      it 'returns a list of objectives by most recently created' do
        expect(described_class.recent_objectives).to eq [@objective3, @objective2, @objective1]
      end
    end

  end

  describe 'progress' do
    it 'returns 0 if there is no progress for the objective' do
      objective = create(:objective)

      expect(objective.progress).to eq 0
    end
    it 'returns 1 if progress has been incremeted by the amount of 1' do
      objective = create(:objective)
      progress = create(:progress, amount: 1, objective_id: objective.id)

      expect(objective.progress).to eq 1
    end
  end

  describe 'target_date' do
    it 'returns 9999-12-31 if there is not a targetdate set' do
      objective = create(:objective)
      expect(objective.target_date).to eq '9999-12-31'.to_date
    end

    it 'returns the target date if there is one set' do
      objective = create(:objective_with_targetdate)
      expect(objective.target_date).to eq objective.targetdate
    end
  end

  describe 'pace' do
    it 'returns (total progress) / (days elapsed) when progress is available' do
      objective = create(:objective, :with_progress, created_at: Time.now - 5.days)
      pace = objective.progress / 5.0
      expect(objective.pace).to eq pace.round(2)
    end

    it 'returns 0 if there has been no progress' do
      objective = create(:objective)
      expect(objective.pace).to eq 0
    end
  end

  describe 'most_updated_at' do
    it 'returns the updated_at date from itself if there is no progress' do
      objective = create(:objective)
      expect(objective.most_updated_at).to eq objective.updated_at
    end

    it 'returns the latest progress updated_at date if it is greater than the current updated_at date' do
      objective = create(:objective)
      progress  = create(:progress, objective: objective)
      expect(objective.most_updated_at).to eq progress.updated_at
    end
  end

  describe 'progress_pct' do
    it 'returns a float with the results from (total progress / target goal)' do
      objective = create(:objective, targetgoal: 100)
      progress  = create(:progress, amount: 40, objective: objective)
      expect(objective.progress_pct).to eq 40.0
    end

    it 'returns 0 if there is no progress on an objective' do
      objective = create(:objective, targetgoal: 100)
      expect(objective.progress_pct).to eq 0
    end
  end

  describe '#recent_objectives_with_progress' do
    before(:each) do
      Objective.delete_all
    end

    it 'returns an empty array if there are no objectives' do
      expect(described_class.recent_objectives_with_progress).to eq []
    end

    it 'returns an array of 1 hash if 1 objective is available' do
      o = create(:objective)
      expect(described_class.recent_objectives_with_progress).to eq [{id: o.id, name: o.name, description: o.description, targetgoal: o.targetgoal, targetdate: o.target_date, progress: o.progress, pace: o.pace, progress_pct: o.progress_pct, created_at: o.created_at.to_s, updated_at: o.updated_at.to_s }]
    end

    it 'returns an array of 2 hashes in most recent order if 2 objectives are available' do
      o = create(:objective)
      p = create(:objective)
      expect(described_class.recent_objectives_with_progress).to eq [
        {id: p.id, name: p.name, description: p.description, targetgoal: p.targetgoal, targetdate: p.target_date, progress: p.progress, pace: p.pace, progress_pct: p.progress_pct, created_at: p.created_at.to_s, updated_at: p.updated_at.to_s },
        {id: o.id, name: o.name, description: o.description, targetgoal: o.targetgoal, targetdate: p.target_date, progress: o.progress, pace: o.pace, progress_pct: o.progress_pct, created_at: o.created_at.to_s, updated_at: o.updated_at.to_s }
      ]
    end
  end
end
