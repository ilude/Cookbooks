require "fnordmetric"

FnordMetric.namespace :myapp do

  timeseries_gauge :number_of_notifications,
    :group => "Notifications",
    :title => "Number of Notifications",
    :key_nouns => ["Customer Order", "Purchase Order", "Invoice"],
    :series => [:order, :po, :invoice],
    :resolution => 10.second

  gauge :events_per_hour, :tick => 1.hour
  gauge :events_per_second, :tick => 1.second
  gauge :events_per_minute, :tick => 1.minute

  event :notification do
    incr :events_per_hour
    incr :events_per_minute
    incr :events_per_second

    incr :number_of_notifications, data[:type].to_sym, 1

  end

  widget 'TechStats', {
    :title => "Events Numbers",
    :type => :numbers,
    :width => 100,
    :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
    :offsets => [1,3,5,10],
    :autoupdate => 1
  }

  widget 'TechStats', {
    :title => "Events per Minute",
    :type => :timeline,
    :width => 100,
    :gauges => :events_per_minute,
    :include_current => true,
    :autoupdate => 30
  }

  widget 'TechStats', {
    :title => "Events/Second",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_second,
    :include_current => true,
    :plot_style => :areaspline,
    :autoupdate => 1
  }


  widget 'TechStats', {
    :title => "Events per Hour",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_hour,
    :include_current => true,
    :autoupdate => 30
  }


end

#FnordMetric.standalone

FnordMetric::Web.new(:port => 4242)
FnordMetric::Acceptor.new(:protocol => :udp, :port => 2323)
FnordMetric::Worker.new
FnordMetric.run
