class Progress < ActiveRecord::Base
  belongs_to :progressable, polymorphic: true

  #validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    progress = []

    # Pull all progress associated with the subobjectives for that objective
    objective.subobjectives.each do |subobjective|
      subobjective.progresses.recent_progress.each do |p|
        progress << {name: subobjective.name, type: "Subobjective", subobjective_id: p.progressable_id, id: p.id, amount: p.amount, created_at: p.created_at.to_s, created_at_date: p.created_at}
      end
    end

    return progress.sort_by {|p| p[:created_at_date]}.reverse
  end

  def self.all_progress
    progress = []
    Progress.all.each do |p|
        progress << {id: p.id, amount: p.amount, type: "Subobjective", subobjective_id: p.progressable_id, updated_at: p.updated_at.to_s}
    end
    progress
  end

end
