#Tasks from delayed/recipes
after 'deploy:update', 'delayed_job:restart'
