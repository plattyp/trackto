class Objective < ActiveRecord::Base
  belongs_to :user
  has_many :subobjectives, :dependent => :destroy

  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

  scope :recent_objectives, -> { order('objectives.created_at DESC') }

  def self.objectives_with_progress(user)
    objectives = []
    user.objectives.recent_objectives.each do |p|
      objectives << {id: p.id, name: p.name, description: p.description, progress: p.obj_progress, archived: p.is_archived?, created_at: p.created_at.to_s, updated_at: p.updated_at.to_s}
    end
    objectives
  end

  def self.get_all_subobjectives_not_progressed_today(user)
    subobjectives = []
    user.objectives.each do |o|
      o.subobjectives.each do |s|
        if s.has_no_progress_today?
          subobjectives << {id: s.id, name: s.name, description: s.description, objective_id: o.id}
        end
      end
    end
    subobjectives
  end

  def get_subobjectives
    subobjectives = []
    self.subobjectives.each do |p|
      subobjectives << {id: p.id, name: p.name, description: p.description, progress: p.progress, created_at: p.created_at.to_s}
    end
    subobjectives
  end

  def is_archived?
    archived || false
  end

  def obj_progress
    has_progress? ? progress : 0
  end

  def self.objective_count_by_user(user)
    user.objectives.count
  end

  def self.total_progress_per_user(user)
    progress = 0
    user.objectives.each do |o|
      o.subobjectives.each do |s|
        progress += s.progress
      end
    end
    progress
  end

  private

  def has_progress?
    if progress
      progress > 0 ? true : false
    end
  end

end
