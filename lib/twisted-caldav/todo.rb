module Icalendar
  class Todo < Component
    ical_component :alarms

    ical_property :ip_class
    ical_property :completed
    ical_property :created
    ical_property :description
    ical_property :dtstamp, :timestamp
    ical_property :dtstart, :start
    ical_property :geo
    ical_property :last_modified
    ical_property :location
    ical_property :organizer
    ical_property :percent_complete, :percent
    ical_property :priority
    ical_property :recurid, :recurrence_id
    ical_property :sequence, :seq
    ical_property :status
    ical_property :summary
    ical_property :uid, :user_id
    ical_property :url

    ical_property :due
    ical_property :duration

    ical_multi_property :attach, :attachment, :attachments
    ical_multiline_property :attendee, :attendee, :attendees
    ical_multi_property :categories, :category, :categories
    ical_multi_property :comment, :comment, :comments
    ical_multi_property :contact, :contact, :contacts
    ical_multi_property :exdate, :exception_date, :exception_dates
    ical_multi_property :exrule, :exception_rule, :exception_rules
    ical_multi_property :rstatus, :request_status, :request_statuses
    ical_multi_property :related_to, :related_to, :related_tos
    ical_multi_property :resources, :resource, :resources
    ical_multi_property :rdate, :recurrence_date, :recurrence_dates
    ical_multi_property :rrule, :recurrence_rule, :recurrence_rules
    
    def initialize()
      super("VTODO")

      sequence 0
      timestamp DateTime.now
    end

  end
end