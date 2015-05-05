class Objective < ActiveRecord::Base
  belongs_to :user
  has_many :progresses, :dependent => :destroy

  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }
  validates :targetgoal, numericality: { only_integer: true, greater_than: 0}
  validate :target_date_greater_than_today, on: :create

  scope :recent_objectives, -> { order('objectives.created_at DESC') }

  def self.objectives_with_progress(user)
    objectives = []
    user.objectives.recent_objectives.each do |p|
      objectives << {id: p.id, name: p.name, description: p.description, targetgoal: p.targetgoal, targetdate: p.target_date, progress: p.progress, pace: p.pace, progress_pct: p.progress_pct, created_at: p.created_at.to_s, updated_at: p.most_updated_at.to_s}
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

  def progress_pct
    (progress.to_f / targetgoal.to_f).round(2) * 100
  end

  def most_updated_at
    if has_progress?
      most_recent_progress > updated_at ? most_recent_progress : updated_at
    else
      updated_at
    end
  end

  private

  def most_recent_progress
    progresses.maximum(:updated_at) if has_progress?
  end

  def has_progress?
    progress > 0
  end

  def target_date_greater_than_today
    return if targetdate.blank?
    if (Time.zone.now - targetdate.to_datetime) > 0
      errors.add(:targetdate, "must be greater than or equal to #{Date.today}")
    end
  end

  def days_difference
    (Time.zone.now - created_at.to_datetime).to_i / 1.day
  end

  def days_elapsed
    days_difference == 0 ? 1 : days_difference
  end

end
