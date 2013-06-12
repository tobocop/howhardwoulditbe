plink-pivotal
=============

www rewrite in rails with pivotal labs.

Getting Started
---

* install freetds

    brew install freetds

	- If issues with tiny TDS gem libiconv missing
		brew install libiconv
		gem install tiny_tds -- --with-freetds-include=/usr/local/include --with-freetds-lib=/usr/local/lib --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib

* database.yml

* whitelist IP in RDS

* bundle

* open a Rails console and `User.first`. If you see a user, you did it.
