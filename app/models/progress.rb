class Progress < ActiveRecord::Base
  belongs_to :objective

  validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }
  validate :new_progress_total_cannot_be_greater_then_objective_goal, on: :create

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    progress = []
    objective.progresses.recent_progress.each do |p|
      progress << {id: p.id, amount: p.amount, created_at: p.created_at.to_s}
    end
    progress
  end

  def new_progress_total_cannot_be_greater_then_objective_goal
    objective = Objective.find_by_id(objective_id)
    if objective
      if potential_progress_amount(objective) > objective.targetgoal
        errors.add(:amount, "can't be greater than target goal")
      end
    end
  end

  private

  def potential_progress_amount(objective)
    objective.progress + (amount || 0)
  end
end
