Delayed::Worker.max_attempts = 5
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.plugins << DJExceptionalPlugin

