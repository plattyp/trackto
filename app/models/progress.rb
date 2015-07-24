class Progress < ActiveRecord::Base
  belongs_to :progressable, polymorphic: true

  #validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }
  validate :new_progress_total_cannot_be_greater_then_objective_goal, on: :create

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    progress = []

    # Pull all progress associated with the objective
    objective.progresses.recent_progress.each do |p|
      progress << {name: objective.name, type: "Objective", parent_id: p.progressable_id, id: p.id, amount: p.amount, created_at: p.created_at.to_s, created_at_date: p.created_at}
    end

    # Pull all progress associated with the subobjectives for that objective
    objective.subobjectives.each do |subobjective|
      subobjective.progresses.recent_progress.each do |p|
        progress << {name: subobjective.name, type: "Subobjective", parent_id: p.progressable_id, id: p.id, amount: p.amount, created_at: p.created_at.to_s, created_at_date: p.created_at}
      end
    end

    return progress.sort_by {|p| p[:created_at_date]}.reverse
  end

  def self.all_progress
    progress = []
    Progress.all.each do |p|
      if p.progressable_type === "Objective" 
        progress << {id: p.id, amount: p.amount, type: "Objective", id: p.progressable_id, updated_at: p.updated_at.to_s}
      else
        progress << {id: p.id, amount: p.amount, type: "Subobjective", id: p.progressable_id, updated_at: p.updated_at.to_s}
      end
    end
    return progress
  end

  def new_progress_total_cannot_be_greater_then_objective_goal
    if progressable_type === "Objective"
      objective = Objective.find_by_id(progressable_id)
      if objective
        if potential_progress_amount(objective) > objective.targetgoal
          errors.add(:amount, "can't be greater than target goal")
        end
      end
    end
  end

  private

  def potential_progress_amount(objective)
    objective.progress + (amount || 0)
  end
end
