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

  def self.progress_overview_by_user_by_timeframe(userId, timeframe, limit, offsetseconds)
    query = ""
    tf = timeframe.downcase
    if tf === 'days'
      query = "SELECT 
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD') AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " days')
              AND o.user_id = " + userId.to_s + "
              GROUP BY
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')
              ORDER BY
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')"
    elsif tf === 'weeks'
      query = "SELECT 
              date_trunc('week', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " weeks')
              AND o.user_id = " + userId.to_s + "
              GROUP BY
              date_trunc('week', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date
              ORDER BY
              date_trunc('week', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date"
    elsif tf === 'months'
      query = "SELECT 
              date_trunc('month', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " months')
              AND o.user_id = " + userId.to_s + "
              GROUP BY
              date_trunc('month', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date
              ORDER BY
              date_trunc('month', to_char(p.created_at + interval '" + offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date"
    end

    if !query.blank?
      mappedresults = {}
      results = ActiveRecord::Base.connection.execute(query)
      results.each do |r|
        if tf === 'days'
          mappedresults[r['x']] = r['progress']
        elsif tf === 'weeks'
          mappedresults[return_formatted_week(r['x'])] = r['progress']
        elsif tf === 'months'
          mappedresults[return_formatted_month(r['x'])] = r['progress']
        end
      end
      return mappedresults
    end

    return {}
  end

  def self.progress_overview_by_subobjective_by_timeframe(userId, objectiveId, timeframe, limit, offsetseconds)
    query = ""
    tf = timeframe.downcase
    if tf === 'days'
      query = "
              SELECT 
              s.id AS subobjective_id,
              s.name AS subobjective,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD') AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " days')
              AND o.user_id = " + userId.to_s + "
              AND o.id = " + objectiveId.to_s + "
              GROUP BY
              s.id,
              s.name,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')
              ORDER BY
              s.id,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')"
    elsif tf === 'weeks'
      query = "
              SELECT 
              s.id AS subobjective_id,
              s.name AS subobjective,
              date_trunc('week', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " weeks')
              AND o.user_id = " + userId.to_s + "
              AND o.id = " + objectiveId.to_s + "
              GROUP BY
              s.id,
              s.name,
              date_trunc('week', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date
              ORDER BY
              s.id,
              date_trunc('week', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date"
    elsif tf === 'months'
      query = "
              SELECT 
              s.id AS subobjective_id,
              s.name AS subobjective,
              date_trunc('month', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " months')
              AND o.user_id = " + userId.to_s + "
              AND o.id = " + objectiveId.to_s + "
              GROUP BY
              s.id,
              s.name,
              date_trunc('month', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date
              ORDER BY
              s.id,
              date_trunc('month', to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')::timestamp)::date"
    end

    if !query.blank?
      mappedresults = {}
      results = ActiveRecord::Base.connection.execute(query)
      results.group_by{|s| s['subobjective']}.each do |k,v|
        values = {}
        v.each do |p|
          if tf === 'days'
            values[p['x']] = p['progress']
          elsif tf === 'weeks'
            values[return_formatted_week(p['x'])] = p['progress']
          elsif tf === 'months'
            values[return_formatted_month(p['x'])] = p['progress']
          end
        end
        mappedresults[k] = values
      end
      return mappedresults
    end

    return {}
  end
  
  def self.all_progress
    progress = []
    Progress.all.each do |p|
        progress << {id: p.id, amount: p.amount, type: "Subobjective", subobjective_id: p.progressable_id, updated_at: p.updated_at.to_s}
    end
    progress
  end

  private

  def self.return_formatted_week(dateString)
    date = Date.strptime(dateString, "%Y-%m-%d")
    month = date.strftime("%B")
    day = date.strftime("%d")

    if (month === "June" || month === "July")
      month = month
    else
      month = month[0,3]
    end

    return month + " " + day.to_s
  end

  def self.return_formatted_month(dateString)
    date = Date.strptime(dateString, "%Y-%m-%d")
    month = date.strftime("%B")
    year = date.strftime("%Y")

    if (month === "June" || month === "July")
      month = month
    else
      month = month[0,3]
    end

    return month + " " + year.to_s
  end

end
