class Event < Content
  has_one :event_data

  delegate :event_date, :title, :subtitle, :body, :to => :event_data, :allow_nil => true

  accepts_nested_attributes_for :event_data

  def self.create_agenda_entry(attributes)
    event = self.new
    event.event_data = EventData.create attributes
    event.save!
    event
  end

  def self.general_agenda(filters)
    start_date, end_date = calendar_bounds(3, filters)

    events = Event.select('event_date, duration, title, subtitle, body')
         .includes(:event_data)
         .moderated
         .where('event_data.event_date >= ? AND event_data.event_date <= ?', start_date, end_date)
         .order('event_data.event_date asc')

         events_to_agenda(events, start_date, end_date)
  end

  def self.from_area(area, weeks, filters)
    start_date, end_date = calendar_bounds(weeks, filters)

    events = Event.select('event_date, duration, title, subtitle, body')
         .includes(:event_data)
         .joins(:author => :areas)
         .moderated
         .where('areas.id = ? AND event_data.event_date >= ? AND event_data.event_date <= ?', area.id, start_date, end_date)
         .order('event_data.event_date asc')

    events_to_agenda(events, start_date, end_date)
  end

  def self.from_user(user, weeks, filters)
    start_date, end_date = calendar_bounds(weeks, filters)

    events = Event.select('event_date, duration, title, subtitle, body')
         .includes(:event_data)
         .joins(:author)
         .moderated
         .where('users.id = ? AND event_data.event_date >= ? AND event_data.event_date <= ?', user.id, start_date, end_date)
         .order('event_data.event_date asc')

    events_to_agenda(events, start_date, end_date)
  end

  def date
  end

  def time
    event_date.strftime('%H:%M')
  end

  def text
    title
  end

  def as_json(options = {})
    super({
      :event_date      => event_date,
      :title           => title,
      :subtitle        => subtitle,
      :body            => body,
      :location        => location,
      :latitude        => latitude,
      :longitude       => longitude
    })
  end

  def facebook_share_message
    title.truncate(140)
  end

  def twitter_share_message
    title.truncate(140)
  end

  def email_share_message
    title
  end

  def self.calendar_bounds(weeks, filters)
    calendar_date = Date.current
    if filters[:next_month].present?
      calendar_date = Date.current.advance(:months => filters[:next_month].to_i)
    end

    beginning_of_calendar = calendar_date.beginning_of_week
    end_of_calendar = calendar_date.advance(:weeks => weeks).end_of_week
    return beginning_of_calendar, end_of_calendar
  end

  def self.events_to_agenda(events, beginning_of_week, end_of_week)
    agenda      = events.group_by{|e| e.event_date.day }
    days        = beginning_of_week..end_of_week
    agenda_json = JSON.generate(events.map{|event| {
      :title      => event.title,
      :date       => I18n.localize(event.event_date, :format => '%d, %B de %Y'),
      :when       => event.event_date.strftime('%H:%M'),
      :where      => event.try(:location),
      :lat        => event.latitude,
      :lon        => event.longitude,
      :event_id   => event.id
    }}.group_by{|event| [event[:lat], event[:lon]]}.values).html_safe

    return agenda, days, agenda_json
  end

end
