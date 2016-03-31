# config/initializers/delayed_job_config.rb
# added [jrl] 01/2015
Delayed::Worker.destroy_failed_jobs = false
#Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 10.minutes
Delayed::Worker.read_ahead = 5
Delayed::Worker.default_queue_name = 'default'
#don't run delayed_jobs in test environment
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))