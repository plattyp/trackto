class Objective < ActiveRecord::Base
  has_many :progresses, :dependent => :destroy

  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }
  validates :targetgoal, numericality: { only_integer: true }

  scope :recent_objectives, -> { order('objectives.created_at DESC') }

  def self.recent_objectives_with_progress
    objectives = []
    Objective.recent_objectives.each do |p|
      objectives << {id: p.id, name: p.name, description: p.description, targetgoal: p.targetgoal, targetdate: p.target_date, progress: p.progress, pace: p.pace, created_at: p.created_at.to_s, updated_at: p.updated_at.to_s}
    end
    objectives
  end

  def pace
    progress == 0 ? 0.00 : (progress/days_elapsed).round(2)
  end

  def progress
    amount = 0
    self.progresses.each { |p| amount += p.amount }
    amount
  end

  def target_date
    targetdate || "9999-12-31".to_date
  end

  private

  def days_difference
    (Time.zone.now - created_at.to_datetime).to_i / 1.day
  end

  def days_elapsed
    days_difference == 0 ? 1 : days_difference
  end

end
