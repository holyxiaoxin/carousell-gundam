require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '3s' do

end

scheduler.join
