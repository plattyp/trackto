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
        expect(described_class.all_objectives).to eq [@objective3, @objective2, @objective1]
      end
    end

  end
end
