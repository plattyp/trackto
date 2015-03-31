class Objective < ActiveRecord::Base
  has_many :progresses, :dependent => :destroy

  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }
  validates :targetgoal, numericality: { only_integer: true }

  scope :recent_objectives, -> { order('objectives.created_at DESC') }

  def self.recent_objectives_with_progress
    objectives = []
    Objective.recent_objectives.each do |p|
      objectives << {id: p.id, name: p.name, description: p.description, targetgoal: p.targetgoal, progress: p.progress, created_at: p.created_at.to_s, updated_at: p.updated_at.to_s}
    end
    objectives
  end

  def progress
    amount = 0
    self.progresses.each { |p| amount += p.amount }
    amount
  end
end
