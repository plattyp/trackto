class Objective < ActiveRecord::Base
  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }

  scope :all_objectives, -> { order('objectives.created_at DESC') }
end
