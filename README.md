plink-pivotal
=============

www rewrite in rails with pivotal labs.

Getting Started
---

We use a local Windows VM with SQL Server Express in development.

* install freetds on host

    brew install freetds

	- If issues with tiny TDS gem libiconv missing
		brew install libiconv
		gem install tiny_tds -- --with-freetds-include=/usr/local/include --with-freetds-lib=/usr/local/lib --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib

* point database.yml at the SQL Server running on Windows VM

* bundle

* rake db:schema:load

* rake db:create_views

* rake db:seed

* open a Rails console and `User.first`. If you see a user, you did it.
