class Objective < ActiveRecord::Base
  belongs_to :user
  has_many :subobjectives, :dependent => :destroy
  accepts_nested_attributes_for :subobjectives

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
          subobjectives << {id: s.id, name: s.name, description: s.description, objective_id: o.id, objective_name: o.name}
        end
      end
    end
    subobjectives
  end

  def self.find_by_id_and_user(objectiveId, user)
    objective = Objective.find_by_id(objectiveId)

    if objective.user_id = user.id
      return objective
    else
      return nil
    end
  end

  def get_subobjectives
    subobjectives = []
    self.subobjectives.each do |p|
      subobjectives << {id: p.id, name: p.name, description: p.description, progress: p.progress, created_at: p.created_at.to_s}
    end
    subobjectives
  end

  def get_subobjectives_total_progress
    total = 0
    self.subobjectives.each do |p|
      total += p.progress
    end
    total
  end

  def get_longest_streak_for_a_subobjective_in_last_days(days)
    query = ""
    if days > 0
      query = "SELECT
              MAX(streak) AS streak
              FROM
              (
              SELECT
              date,
              grp,
              row_number() OVER (PARTITION BY sub_id, grp ORDER BY date) AS streak
              FROM
              (
              SELECT
              sub_id,
              date,
              date::date - '2000-01-01'::date - row_number() OVER (PARTITION BY sub_id ORDER BY date) as grp
              FROM
              (
              SELECT
              s.id AS sub_id,
              to_char(p.created_at,'YYYY-MM-DD') AS date,
              sum(p.amount) AS progress
              FROM 
                progresses p
                join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
                join objectives o on s.objective_id = o.id
              WHERE
                o.id = " + id.to_s + "
                AND p.created_at > (current_date - interval '" + days.to_s + " days')
              GROUP BY
                s.id,
                to_char(p.created_at,'YYYY-MM-DD')
              ) t ) s ) o"
    end

    streak = 0
    if !query.blank?
      results = ActiveRecord::Base.connection.execute(query)
      streak = results[0]['streak'] || 0
    end
    return streak 
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
