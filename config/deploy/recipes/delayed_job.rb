#Tasks from delayed/recipes
set :delayed_job_args, '--queue=default'
after 'deploy:update', 'delayed_job:restart'
