Security Cert Overview
=============

CSR's, and private keys can be found on production-cf /home/ubuntu/plink_inc_certs/goodsearch.plink.com
The CRT files can be downloaded from godaddy

On a high level, all security certs are setup as follows:
	1. An amazon ELB is configured to forward http and https traffic to the same port (443 or others in the CF white label setup)
	2. The security cert is installed to amazon with a chain file
	3. The security cert is installed on the machine to serve the cert.

Configuring an amazon ELB to forward traffic to 443
---
1. Log into amazon ec2 and go to the elastic load balancers section and click create new
2. Add a rule to forward port 443 to port 443 on the backened both via https
3. When asked to upload a cert, paste in the information into the fields. You'll need to: (All security certificates are stored in box)
	1. If not present with the cert in box, pem encode the key file with:
		`openssl rsa -in domain.key -out domain.key.pem`
	2. Paste the .key.pem file into the private key field
	3. Paste the contents of the .crt file in the cert field
	4. Paste the contents of the gd_bundle.crt file into the chain field
4. If you receive errors of improperly coded files while uploading, make sure your private key is in pem format
5. If you receive errors that the limit for ssl certs has been reached, use the IAM command line tools from amazon to remove older certs
	found at: (http://aws.amazon.com/developertools/AWS-Identity-and-Access-Management/4143)
	Relevant commands:
		`iam-servercertlistbypath`
		`iam-servercertdel -s [cert_name]`
6. Health Check:
	Ping Target: TCP:80
	Timeout: 10 seconds
	Interval: 30 seconds
	Unhealthy Threshold: 4
	Healthy Threshold: 2
7. Add the relevant instances to the ELB and you're done


Apache SSL setup:
---
	1. you'll need the .key, .crt, and gd_bundle.crt files to setup ssl
	2. SCP the files onto the machine you're setting up SSL on
	3. Move them to /etc/apache2/ssl/[domain_name]
	4. Edit sites-available/default and add the following lines to the vhost you're adding ssl to
		SSLEngine On
		SSLCertificateFile /etc/apache2/ssl/[domain_name]/[.crt file]
		SSLCertificateKeyFile /etc/apache2/ssl/[domain_name]/[.key file]
		SSLCertificateChainFile /etc/apache2/ssl/[domain_name]/[gd_bundle.crt file]
	5. restart apache and check that the cert is correct through all major browsers

Ngninx SSL setup:
---
	1. You'll need the .key file and a .chained.crt file
	2. If there is no .chained.crt file in the box folder, generate it with the following command and add it to box
		`cat www.example.com.crt bundle.crt > www.example.com.chained.crt`
	3. scp the files onto the machine you're installing the cert to and put them in /etc/nginx/ssl-cert/[domain_name]/
	4. Add the following lines to the nginx conf for the server you're adding ssl to:
		ssl_certificate /etc/nginx/ssl-certs/[domain_name]/[.chained.crt file]
		ssl_certificate_key /etc/nginx/ssl-certs/[domain_name]/[.key file]
	5. make sure the listen statement has ssl in it, like:
		listen 443 ssl;
	6. reboot nginx and test the file in all major browsers

Non port 443 setup (white label and reg currently)
---

Nginx and Apache can only serve SSL over unique ports. To get around this, we use amazon's elastic load balancers to forward ssl to a different port
In apache, this is setup in the conf file like so on the vhost:
---
	Adding this to /etc/apache2/ports.conf for your port:
		Listen [custom_port_number]
		NameVirtualHost *:[custom_port_number]

	Adding this to /etc/apache2/sites-available/default
	<VirtualHost *:8087>
	  DocumentRoot /var/www/www.plink.com
	  ServerName  goodsearch.plink.com

	  <Directory "/var/www/www.plink.com">
		Order allow,deny
		Allow from all
	  </Directory>
	  <Directory "/var/www/www.plink.com/config">
		Order allow,deny
		deny from all
	  </Directory>

	  SSLEngine On

	  SSLCertificateFile /etc/apache2/ssl/goodsearch.plink.com/goodsearch.plink.com.crt
	  SSLCertificateKeyFile /etc/apache2/ssl/goodsearch.plink.com/goodsearch.plink.com.key
	  SSLCertificateChainFile /etc/apache2/ssl/goodsearch.plink.com/gd_bundle.crt
	</VirtualHost>

In nginx, the server directive looks like this inside of the specific server block
---
	listen 8081 ssl;
	server_name reg.plink.com;
	ssl_certificate /etc/nginx/ssl-certs/reg.plink.com/reg.plink.com.chained.crt;
	ssl_certificate_key /etc/nginx/ssl-certs/reg.plink.com/reg.plink.com.key;
