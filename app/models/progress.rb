class Progress < ActiveRecord::Base
  belongs_to :objective

  validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    progress = []
    objective.progresses.recent_progress.each do |p|
      progress << {id: p.id, amount: p.amount, created_at: p.created_at.to_s}
    end
    progress
  end
end
