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

  describe '#recent_objectives_with_progress' do
    before(:each) do
      Objective.delete_all
    end

    it 'returns an empty array if there are no objectives' do
      expect(described_class.recent_objectives_with_progress).to eq []
    end

    it 'returns an array of 1 hash if 1 objective is available' do
      o = create(:objective)
      expect(described_class.recent_objectives_with_progress).to eq [{id: o.id, name: o.name, description: o.description, targetgoal: o.targetgoal, progress: o.progress}]
    end

    it 'returns an array of 2 hashes in most recent order if 2 objectives are available' do
      o = create(:objective)
      p = create(:objective)
      expect(described_class.recent_objectives_with_progress).to eq [
        {id: p.id, name: p.name, description: p.description, targetgoal: p.targetgoal, progress: p.progress},
        {id: o.id, name: o.name, description: o.description, targetgoal: o.targetgoal, progress: o.progress}
      ]
    end
  end
end
