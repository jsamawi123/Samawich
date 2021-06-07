DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank CHARACTER SET utf8 COLLATE utf8_general_ci;
USE bank;

CREATE TABLE users ( 
    uname varchar(255) NOT NULL, 
    pass  varchar(255) NOT NULL, 
    fname varchar(255) NOT NULL, 
    lname varchar(255) NOT NULL, 
    email varchar(255) NOT NULL,
    PRIMARY KEY (uname)
);

CREATE TABLE accounts ( 
    account_id INTEGER NOT NULL AUTO_INCREMENT, 
    uname varchar(255) NOT NULL, 
    balance INTEGER, 
    PRIMARY KEY (account_id),
    FOREIGN KEY(uname) REFERENCES users(uname)
);

