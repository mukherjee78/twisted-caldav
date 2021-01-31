require 'builder'

module TwistedCaldav
  NAMESPACES = { "xmlns:d" => 'DAV:', "xmlns:c" => "urn:ietf:params:xml:ns:caldav" }
  module Request
    class Base
      def initialize
        @xml = Builder::XmlMarkup.new(:indent => 2)
        @xml.instruct!
      end
      attr :xml
    end

    class Mkcalendar < Base
      attr_accessor :displayname, :description

      def initialize(displayname = nil, description = nil)
        @displayname = displayname
        @description = description
      end

      def to_xml
        xml.c :mkcalendar, NAMESPACES do
          xml.d :set do
            xml.d :prop do
              xml.d :displayname, displayname unless displayname.to_s.empty?
              xml.tag! "c:calendar-description", description, "xml:lang" => "en" unless description.to_s.empty?
            end
          end
        end
      end
    end

    class ReportVEVENT < Base
      attr_accessor :tstart, :tend

      def initialize( tstart=nil, tend=nil )
        @tstart = tstart
        @tend   = tend
        super()
      end

      def to_xml
        xml.c 'calendar-query'.intern, NAMESPACES do
          xml.d :prop do
            #xml.d :getetag
            xml.c 'calendar-data'.intern
          end
          xml.c :filter do
            xml.c 'comp-filter'.intern, :name=> 'VCALENDAR' do
              xml.c 'comp-filter'.intern, :name=> 'VEVENT' do
                xml.c 'time-range'.intern, :start=> "#{tstart}Z", :end=> "#{tend}Z"
              end
            end
          end
        end
      end
    end

    class ReportVTODO < Base
      def to_xml
        xml.c 'calendar-query'.intern, NAMESPACES do
          xml.d :prop do
            xml.d :getetag
            xml.c 'calendar-data'.intern
          end
          xml.c :filter do
            xml.c 'comp-filter'.intern, :name=> 'VCALENDAR' do
              xml.c 'comp-filter'.intern, :name=> 'VTODO'
            end
          end
        end
      end
    end
  end
end
