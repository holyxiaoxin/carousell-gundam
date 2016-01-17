require 'rufus-scheduler'
require_relative 'job.rb'

scheduler = Rufus::Scheduler.new
gundam_job = GundamJob.new

scheduler.every '15s' do
  gundam_job.update
  gundam_job.notify
end

scheduler.join
