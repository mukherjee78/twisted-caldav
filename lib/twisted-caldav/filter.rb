module TwistedCaldav
  module Filter
    class Base
      attr_accessor :parent, :child
      
      def to_xml(xml = Builder::XmlMarkup.new(:indent => 2))
        if parent
          parent.to_xml
        else
          build_xml(xml)
        end
      end
      
      def build_xml(xml)
        #do nothing
      end
      
      def child=(child)
        @child = child
        child.parent = self
      end
    end

    class Component < Base
      attr_accessor :name
      
      def initialize(name, parent = nil)
        self.name = name
        self.parent = parent
      end
      
      def time_range(range)
        self.child = TimeRange.new(range, self)
      end
      
      def uid(uid)
        self.child = Property.new("UID", uid, self)
      end
      
      def build_xml(xml)
        xml.tag! "cal:comp-filter", :name => name do
          child.build_xml(xml) unless child.nil? 
        end
      end
    end

    class TimeRange < Base
      attr_accessor :range
      
      def initialize(range, parent = nil)
        self.range = range
        self.parent = parent
      end
      
      def build_xml(xml)
        xml.tag! "cal:time-range",
          :start => range.begin.to_ical,
          :end   => range.end.to_ical
      end
    end

    class Property < Base
      attr_accessor :name, :text
      
      def initialize(name, text, parent = nil)
        self.name = name
        self.text = text
        self.parent = parent
      end
      
      def build_xml(xml)
        xml.tag! "cal:prop-filter", :name => self.name do
          xml.tag! "cal:text-match", self.text, :collation => "i;octet"
        end
      end
    end
  end
end
