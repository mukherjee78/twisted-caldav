twisted-caldav
==============

[![Gem Version](https://badge.fury.io/rb/twisted-caldav.svg)](http://badge.fury.io/rb/twisted-caldav)

Ruby client for searching, creating, editing calendar and tasks.

Tested with ubuntu based calendar server installation.

It is a modified version of another caldav client under MIT license

https://github.com/n8vision/caldav-icloud

## Installation

```bash
gem install 'twisted-caldav'
```

## Usage

```ruby
require 'twisted-caldav'

u = 'user1'

cal = TwistedCaldav::Client.new(uri: "http://yourserver.com:8008/calendars/users/#{u}/calendar/", user: u , password: 'xxxxxx')
```

### Find events

```ruby
result = cal.find_events(start: '2014-04-01', end: '2014-04-15')
```

### Create event

```ruby
result = cal.create_event(start: '2014-04-12 10:00', end: '2014-04-12 12:00', title: 'Meeting With Me', description: 'Meeting about nothing...:D')
```
