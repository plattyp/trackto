class Progress < ActiveRecord::Base
  belongs_to :objective

  validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    objective.progresses.recent_progress
  end
end
