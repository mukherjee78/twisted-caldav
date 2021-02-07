module TwistedCaldav
  class Client
    include Icalendar
    attr_accessor :host, :port, :url, :user, :password, :ssl

    def format=(fmt)
      @format = fmt
    end

    def format
      @format ||= Format::Debug.new
    end

    def initialize(data)
      unless data[:proxy_uri].nil?
        proxy_uri = URI(data[:proxy_uri])
        @proxy_host = proxy_uri.host
        @proxy_port = proxy_uri.port.to_i
      end

      uri = URI(data[:uri])
      @host = uri.host
      @port = uri.port.to_i
      @url = uri.path
      @user = data[:user]
      @password = data[:password]
      @ssl = uri.scheme == 'https'

      if data[:authtype].nil?
        @authtype = 'basic'
      else
        initialize_authtype(data)
      end
    end

    def __create_http
      http = if @proxy_uri.nil?
               Net::HTTP.new(@host, @port)
             else
               Net::HTTP.new(@host, @port, @proxy_host, @proxy_port)
             end
      if @ssl
        http.use_ssl = @ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http
    end

    def find_events(data)
      result = ''
      events = []
      res = nil
      __create_http.start do |http|
        req = Net::HTTP::Report.new(@url, { 'Content-Type' => 'application/xml' })
        req.add_field 'Depth', '1'
        add_auth(req, 'REPORT')
        if data[:start].is_a? Integer
          req.body = TwistedCaldav::Request::ReportVEVENT.new(Time.at(data[:start]).utc.strftime('%Y%m%dT%H%M%S'),
                                                              Time.at(data[:end]).utc.strftime('%Y%m%dT%H%M%S')).to_xml
        else
          req.body = TwistedCaldav::Request::ReportVEVENT.new(Time.parse(data[:start]).utc.strftime('%Y%m%dT%H%M%S'),
                                                              Time.parse(data[:end]).utc.strftime('%Y%m%dT%H%M%S')).to_xml
        end
        res = http.request(req)
      end
      errorhandling res
      xml = REXML::Document.new(res.body)
      REXML::XPath.each(xml, '//c:calendar-data/', { 'c' => 'urn:ietf:params:xml:ns:caldav' }) { |c| result << c.text }
      r = Icalendar::Calendar.parse(result)
      if r.empty?
        false
      else
        r.each do |calendar|
          calendar.events.each do |event|
            events << event
          end
        end
        events
      end
    end

    def find_event(uuid)
      res = nil
      __create_http.start do |http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")
        add_auth(req, 'GET')
        res = http.request(req)
      end
      errorhandling res
      begin
        r = Icalendar::Calendar.parse(res.body)
      rescue
        false
      else
        r.first.events.first
      end
    end

    def delete_event(uuid)
      res = nil
      __create_http.start do |http|
        req = Net::HTTP::Delete.new("#{@url}/#{uuid}.ics")
        add_auth(req, 'DELETE')
        res = http.request(req)
      end
      errorhandling res
      # accept any success code
      return true if res.code.to_i.between?(200, 299)

      false
    end

    def create_event(event)
      c = Icalendar::Calendar.new

      cal_event = c.event do |e|
        e.dtstart = Icalendar::Values::DateOrDateTime.new(datetime_format(event[:start])).call
        e.dtend = Icalendar::Values::DateOrDateTime.new(datetime_format(event[:end])).call
        e.categories = event[:categories] # Array
        e.contact = event[:contacts] # Array
        e.attendee = event[:attendees] # Array
        e.duration = event[:duration]
        e.summary = event[:title]
        e.description = event[:description]
        e.ip_class = event[:ip_class] # PUBLIC, PRIVATE, CONFIDENTIAL
        e.transp = event[:transp] # OPAQUE (busy, by default) or TRANSPARENT (free)
        e.location = event[:location]
        e.geo = event[:geo_location]
        e.status = event[:status]
        e.url = event[:url]
        e.rrule = event[:rrule]
      end

      cstring = c.to_ical
      res = nil
      http = Net::HTTP.new(@host, @port)
      __create_http.start do |http|
        req = Net::HTTP::Put.new("#{@url}/#{cal_event.uid}.ics")
        req['Content-Type'] = 'text/calendar'
        add_auth(req, 'PUT')
        req.body = cstring
        res = http.request(req)
      end
      errorhandling res
      find_event cal_event.uid
    end

    def update_event(event)
      #TODO... fix me
      return create_event event if delete_event event[:uid]

      false
    end

    def add_alarm(tevent, altCal = "Calendar")
    end

    private

    def initialize_authtype(data)
      @authtype = data[:authtype]
      case @authtype
      when 'digest'
        @digest_auth = Net::HTTP::DigestAuth.new
        @duri = URI.parse data[:uri]
        @duri.user = @user
        @duri.password = @password
      when 'basic'
        # this is fine for us
      else
        raise UnsupportedAuthTypeError
      end
    end

    def digestauth(method)
      h = Net::HTTP.new @duri.host, @duri.port
      if @ssl
        h.use_ssl = @ssl
        h.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = Net::HTTP::Get.new @duri.request_uri

      res = h.request req
      # res is a 401 response with a WWW-Authenticate header

      @digest_auth.auth_header @duri, res['www-authenticate'], method
    end

    def add_auth(request, verb)
      if @authtype == 'digest'
        request.add_field 'Authorization', digestauth(verb)
      else
        request.basic_auth @user, @password
      end
    end

    def entry_with_uuid_exists?(uuid)
      res = nil

      __create_http.start do |http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")
        if @authtype == 'digest'
          req.add_field 'Authorization', digestauth('GET')
        else
          req.basic_auth @user, @password
        end

        res = http.request(req)
      end
      begin
        errorhandling res
        Icalendar::Calendar.parse(res.body)
      rescue
        false
      else
        true
      end
    end

    def datetime_format(value)
      if value.is_a?(String)
        datetime_format_ok = value.match?(/\d{8}T\d{6}/)
        return value if datetime_format_ok
      end

      date = value.is_a?(Integer) ? Time.at(value) : Time.parse(value)

      date.utc.strftime('%Y%m%dT%H%M%S')
    end

    def errorhandling(response)
      raise NotExistError if response.code.to_i == 404
      raise AuthenticationError if response.code.to_i == 401
      raise NotExistError if response.code.to_i == 410
      raise UnsupportedMediaTypeError if response.code.to_i == 415
      raise APIError if response.code.to_i >= 500
    end
  end

  class TwistedCaldavError < StandardError
  end

  class AuthenticationError < TwistedCaldavError; end

  class DuplicateError < TwistedCaldavError; end

  class APIError < TwistedCaldavError; end

  class NotExistError < TwistedCaldavError; end

  class UnsupportedMediaTypeError < TwistedCaldavError; end

  class UnsupportedAuthTypeError < TwistedCaldavError; end
end
