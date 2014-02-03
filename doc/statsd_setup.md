StatsD & Librato Configuration
=================
Configuration instructions for review & production boxes

Install Node.js
--------------
1) Install dependencies

`sudo apt-get install g++ curl libssl-dev apache2-utils`

`sudo apt-get install git-core`

2) Run the following commands (*ideally in the /opt directory*)

`git clone git://github.com/ry/node.git`

`cd node`

`./configure`

`make`

`sudo make install`

3) Install NPM

`curl https://npmjs.org/install.sh | sudo sh`

StatsD & Librato Config
--------------
1) Clone the StatsD Repo into /opt

`git clone git://github.com/etsy/statsd.git`

2) Copy the sample statsd.js config file into /shared/config and setup a symlink in the current/config directory.

`ln -s /var/www/plink-www/shared/config/statsd.js /var/www/plink-www/current/config/statsd.js`

3) Repeat step 2 with librato.yml

`ln -s /var/www/plink-www/shared/config/librato.yml /var/www/plink-www/current/config/librato.yml`

Install Librato Node Package
--------------
1) From the install path for StatsD:

`npm install statsd-librato-backend`

Using StatsD as a Service
-------------

1) Install upstart and monit

`apt-get install upstart monit`

2) Create this file “/etc/init/statsd.conf” and add:


    #!upstart
    description "Statsd node.js server"
    author      "Plink"

    start on startup
    stop on shutdown

    script
        export HOME="/root"

        echo $$ > /var/run/statsd.pid
        exec sudo -u www-data /usr/bin/nodejs /opt/statsd/stats.js /opt/statsd/localConfig.js  >> /var/log/statsd.log 2> /var/log/statsd.error.log
    end script

    pre-start script
        # Date format same as (new Date()).toISOString() for consistency
        echo "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Starting" >> /var/log/statsd.log
    end script

    pre-stop script
        rm /var/run/statsd.pid
        echo "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Stopping" >> /var/log/statsd.log
    end script

3) You can now stop & start StatsD with the following commands:

`start statsd`

`stop statsd`

4) To setup monit, create this file `/etc/monit/conf.d/statsd` and add:

    #!monit
    set logfile /var/log/monit.log

    check process nodejs with pidfile "/var/run/statsd.pid"
        start program = "/sbin/start statsd"
        stop program  = "/sbin/stop statsd"

This Will allow you to restart monit by running `/etc/init.d/monit restart`

