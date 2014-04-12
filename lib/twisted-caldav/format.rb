module TwistedCaldav
  module Format
    class Raw
      def method_missing(m, *args, &block)
        return *args
      end
    end

    class Debug < Raw
    end

    class Pretty < Raw
      def parse_calendar(s)
        result = ""
        xml = REXML::Document.new(s)

        REXML::XPath.each( xml, '//c:calendar-data/', {"c"=>"urn:ietf:params:xml:ns:caldav"} ){|c| result << c.text}
        r = Icalendar.parse(result)
        r
      end

      def parse_todo( body )
        result = []
        xml = REXML::Document.new( body )
        REXML::XPath.each( xml, '//c:calendar-data/', { "c"=>"urn:ietf:params:xml:ns:caldav"} ){ |c|
          p c.text
          p parse_tasks( c.text )
          result += parse_tasks( c.text )
        }
        return result
      end

      def parse_tasks( vcal )
        return_tasks = Array.new
        cals = Icalendar.parse(vcal)
        cals.each { |tcal|
          tcal.todos.each { |ttask|  # FIXME
            return_tasks << ttask
          }
        }
        return return_tasks
      end

      def parse_events( vcal )
        Icalendar.parse(vcal)        
      end

      def parse_single( body )
        # FIXME: parse event/todo/vcard
        parse_events( body )
      end
    end
  end
end
