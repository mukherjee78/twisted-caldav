# encoding: UTF-8
require 'spec_helper'

require 'twisted-caldav'

describe TwistedCaldav::Client do

  before(:each) do
    @c = TwistedCaldav::Client.new(
      uri: 'http://localhost:5232/user/calendar',
      user: 'user',
      password: 'password'
    )
  end

  before(:all) do
    class UUID
      def generate
        '360232b0-371c-0130-9e6b-001999638933'
      end
    end
  end

  it 'check Class of client' do
    expect(@c.class.to_s).to eq('TwistedCaldav::Client')
  end

  it 'create one event' do
    uid = UUID.new.generate
    uri_template = Addressable::Template.new 'http://localhost:5232/user/calendar/{uid}.ics'
    stub_request(:any, uri_template).to_return(body: "BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12ss345\nDTEND:20130101T110000\nDTSTAMP:20130101T161708\nDTSTART:20130101T100000\nSEQUENCE:0\nSUMMARY:123ss45\nUID:#{uid}\nX-RADICALE-NAME:#{uid}.ics\nEND:VEVENT\nEND:VCALENDAR",  status: 200)
    event = @c.create_event(start: '2012-12-29 10:00', end: '2012-12-30 12:00', title: '12345', description: '12345 12345')

    expect(event.uid).to eq(uid)
  end

  it 'delete one event' do
    uid = UUID.new.generate
    uri_template = Addressable::Template.new 'http://localhost:5232/user/calendar/{uid}.ics'
    stub_request(:any, uri_template).to_return(body: '1 deleted.',  status: 200)
    r = @c.delete_event(uid)

    expect(r).to be true
  end

  it 'fail to delete one event' do
    uid = UUID.new.generate
    uri_template = Addressable::Template.new 'http://localhost:5232/user/calendar/{uid}.ics'
    stub_request(:any, uri_template).to_return(body: 'not found',  status: 404)

    expect(lambda{ @c.delete_event(uid) }).to raise_error(TwistedCaldav::NotExistError)
  end

  it 'find one event' do
    uid = "5385e2d0-3707-0130-9e49-001999638982"
    uri_template = Addressable::Template.new "http://localhost:5232/user/calendar/#{uid}.ics"
    stub_request(:any, uri_template).to_return(body: "BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12ss345\nDTEND:20130101T110000\nDTSTAMP:20130101T161708\nDTSTART:20130101T100000\nSEQUENCE:0\nSUMMARY:123ss45\nUID:#{uid}\nX-RADICALE-NAME:#{uid}.ics\nEND:VEVENT\nEND:VCALENDAR",  status: 200)
    r = @c.find_event(uid)

    expect(r.uid).to eq(uid)

  end

  it 'find 2 events' do
    uri_template = Addressable::Template.new "http://localhost:5232/user/calendar"
    stub_request(:any, uri_template).to_return(body: "<?xml version=\"1.0\"?>\n<multistatus xmlns=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\">\n  <response>\n    <href>/user/calendar/960232b0-371c-0130-9e6b-001999638982.ics</href>\n    <propstat>\n      <prop>\n        <getetag>\"-5984324385549365166\"</getetag>\n        <C:calendar-data>BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12345\nDTEND:20010202T120000\nDTSTAMP:20130102T161119\nDTSTART:20010202T080000\nSEQUENCE:0\nSUMMARY:6789\nUID:960232b0-371c-0130-9e6b-001999638982\nX-RADICALE-NAME:960232b0-371c-0130-9e6b-001999638982.ics\nEND:VEVENT\nEND:VCALENDAR\n</C:calendar-data>\n      </prop>\n      <status>HTTP/1.1 200 OK</status>\n    </propstat>\n  </response>\n  <response>\n    <href>/user/calendar/98f067a0-371c-0130-9e6c-001999638982.ics</href>\n    <propstat>\n      <prop>\n        <getetag>\"3611068816283260390\"</getetag>\n        <C:calendar-data>BEGIN:VCALENDAR\nPRODID:-//Radicale//NONSGML Radicale Server//EN\nVERSION:2.0\nBEGIN:VEVENT\nDESCRIPTION:12345 12345\nDTEND:20010203T120000\nDTSTAMP:20130102T161124\nDTSTART:20010203T080000\nSEQUENCE:0\nSUMMARY:6789\nUID:98f067a0-371c-0130-9e6c-001999638982\nX-RADICALE-NAME:98f067a0-371c-0130-9e6c-001999638982.ics\nEND:VEVENT\nEND:VCALENDAR\n</C:calendar-data>\n      </prop>\n      <status>HTTP/1.1 200 OK</status>\n    </propstat>\n  </response>\n</multistatus>\n\n",  status: 200)
    r = @c.find_events(start: '2001-02-02 07:00', end: '2000-02-03 23:59')

    expect(r.length).to eq(2)
    expect(r[0].dtstart.strftime('%Y%m%dT%H%M%S')).to eq('20010202T080000')
    expect(r[1].dtend.strftime('%Y%m%dT%H%M%S')).to eq('20010203T120000')
  end
end
