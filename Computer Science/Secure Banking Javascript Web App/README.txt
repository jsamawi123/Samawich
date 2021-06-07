CPSC455 Assignment 3: Web Banking Application with MySQL
By James Samawi, jsamawi@csu.fullerton.edu, 5/25/2021

Install MariaDB server: https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04
$ sudo apt update
$ sudo apt install mariadb-server
$ sudo mysql_secure_installation
$ sudo mariadb
MariaDB [(none)]> GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'solarwinds123' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> exit

Make sure Node is the latest, stable version: https://phoenixnap.com/kb/update-node-js-version
$ npm cache clean -f
$ sudo npm install -g n
$ sudo n stable

Install mysql Node package:
$ npm install mysql

Create the bank database and drop existing database: 
$ mysql --user=admin --password=solarwinds123 bank < bank.sql

Run this Node.js app in the terminal (in project path) with the following command:
$ node app.js

Install packages when prompted by error messages with this command format:
$ npm install <package-name>


Navigate to http://localhost:3000/ and enjoy!


Optional: Inspect the MariaDB server manually
$ mysql --user=admin --password=solarwinds123 bank
MariaDB [bank]> SELECT * FROM users;
MariaDB [bank]> SELECT * FROM accounts;