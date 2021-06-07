"use strict"
const express = require('express');
const session = require('client-sessions');
const bodyParser = require("body-parser");
const helmet = require("helmet");
const xssFilters = require('xss-filters');
const fs = require('fs');
const os = require('os');
const app = express()
const mysql = require("mysql");
const connection = mysql.createConnection({
     host: 'localhost', 
     user:'admin', 
     password: 'solarwinds123',
     database: 'bank',
});

// Content Security Policy (CSP) for HTTP Headers
app.use(helmet.contentSecurityPolicy({
    directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
		styleSrc: ["'self'"],
		objectSrc: ["'none'"],
    }
}));

// Needed to parse the request body
//Note that in version 4 of express, express.bodyParser() was
//deprecated in favor of a separate 'body-parser' module.
app.use(bodyParser.urlencoded({ extended: true }));

// Client Session Setup
app.use(session({
    cookieName: 'session',
    secret: 'ab016.f%4517bf&e2c623a/?2dd2e3#067Eeb4',  // unique signature
    duration: 3 * 60 * 1000,  // 3 minutes
	activeDuration: 1 * 60 * 1000,  // extend by 1 minute on activity
    cookie: {httpOnly: true}
}));

// Verify a username exists given a username, returns true if so and false otherwise
function isUser(uname) {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM users WHERE uname = ?";
        connection.query(sql, [uname], function (err, results, fields) {
            if (results[0] === undefined) {
                return resolve(false);
            }
            return resolve(true);
        });
    });
}

// INSERT new user, given all items required in /Register
function insertUser(uname, pass, fname, lname, email) {
    return new Promise((resolve, reject) => {
        const sql = "INSERT INTO users VALUE (?, ?, ?, ?, ?)";
        connection.query(sql, [uname, pass, fname, lname, email], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            return resolve(results[0]);
        });
    });
}

// INSERT new account (ID will auto increment) given a username
function insertAccount(uname) {
    return new Promise((resolve, reject) => {
        const sql = "INSERT INTO accounts (uname, balance) VALUES (?, 0)";
        connection.query(sql, [uname], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            return resolve(results[0]);
        });
    });
}

// UPDATE account with new balance given an account_id, username and balance value
function updateAccount(val, id, uname) {
    return new Promise((resolve, reject) => {
        const sql = "UPDATE accounts SET balance=? WHERE account_id=? AND uname=?";
        connection.query(sql, [val, id, uname], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            return resolve(results[0]);
        });
    });
}

// GET all values from User table given a username (currently used just to get password)
function getUser(uname) {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM users WHERE uname = ?";
        connection.query(sql, [uname], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            return resolve(results[0]);
        });
    });
}

// GET returns a list of account number(s) from Accounts table given a username
function getAccount(uname) {
    return new Promise((resolve, reject) => {
        const sql = "SELECT account_id FROM accounts WHERE uname = ?";
        connection.query(sql, [uname], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            let i;
            let temp_results = [];
            for (i = 0; i < results.length; i++)
            {
				temp_results.push(results[i].account_id);
			}
			return resolve(temp_results)
        });
    });
}

// GET balance from Accounts table given an account number and username
function getBalance(account_id, uname) {
    return new Promise((resolve, reject) => {
        const sql = "SELECT balance FROM accounts WHERE account_id = ? AND uname = ?";
        connection.query(sql, [account_id, uname], function (err, results, fields) {
            if (err) {
                return reject(err);
            }
            return resolve(results[0].balance);
        });
    });
}


// Get intial response to homepage
app.get('/',function(req,res){
	if(req.session.username)
	{
		res.redirect("/dashboard");
	}
	else
	{
		res.sendFile(__dirname + "/index.html");
	}
});

// Take user to register page
app.get('/register', function(req, res) {
	res.sendFile(__dirname + "/register.html");
});

// Login script when user inputs username and password and clicks Login
app.post('/login',function(req,res){
	// Gather and sanitize username and password
	let username = xssFilters.inHTMLData(req.body.username);
	let password = xssFilters.inHTMLData(req.body.password);

	isUser(username)
		.then(data => {
			if (data === true) // if there was a username
			{
				getUser(username)
					.then(data => {
						let correctPass = data.pass;
						if (correctPass === password) 
						{
							req.session.username = username;
							res.redirect("/dashboard");
						} 
						else 
						{
							res.write("Invalid Credentials");
							res.end();
						}
					})
					.catch(err => console.error(err));
			} else {
				res.write("Invalid Credentials");
				res.end();
			}
		})
		.catch(err => console.error(err));
});

// From register.html - get user input and register account
app.post('/create',function(req,res){
	// Gather and sanitize user inputs
	let username = xssFilters.inHTMLData(req.body.username);
	let password = xssFilters.inHTMLData(req.body.password);
	let firstname = xssFilters.inHTMLData(req.body.fname);
	let lastname = xssFilters.inHTMLData(req.body.lname);
	let address = xssFilters.inHTMLData(req.body.address);
	
	isUser(username)
		.then(data => {
			if (data === false) // if there was no username
			{
				insertUser(username, password, firstname, lastname, address)
					.then(data => data)
					.catch(err => console.error(err));
				insertAccount(username, 0)
					.then(data => data)
					.catch(err => console.error(err));
				console.log('New User Successfully Registered');
			} else {
				console.log("Username already exists");
			}
		})
		.catch(err => console.error(err));
    res.redirect("/");
});

app.use('/dashboard', function(req,res) {
    if(!req.session.username)
    {
      res.redirect("/");
    }

    let uname = req.session.username
    let page = "<html>"
    
    page += "<title> Dashboard</title>"
    page += "<body> <h1> Welcome back to Secure Banking, " + uname + "</h1><br><br>"

    page += "<a href='/add_accounts'>"
    page += "<button>Add Accounts</button> </a><br><br>"
    page += "<a href='/deposit'>"
    page += "<button>Deposit Money</button> </a><br><br>"
    page += "<a href='/withdraw'>"
    page += "<button>Withdraw Money</button> </a><br><br>"
    page += "<a href='/transfer'>"
    page += "<button>Transfer Money</button> </a><br><br>"
    page += "<a href='/logout'>"
    page += "<button>Logout Now!</button></a><br><br>"
    page += "</body></html>"

    res.send(page)
});

app.use('/add_accounts',function(req,res){
	if(!req.session.username)
	{
		res.redirect("/");
	}

	let page = "<html>"
	page += "<body>"
	page += "<h1>Secure Banking Add Account Page</h1><br><br>"

	// start form
	page +="<h2>Click to add an account</h2>"
	page +="<form action='/add_success' method='POST'>"
	page +="<input id='clickMe' type='Submit' value='clickme'><br>"
	page +="</form>"

	// go to main page
	page += "<a href='/dashboard'>"
	page += "<button>Main Page</button> </a><br><br>"
	page += "<a href='/logout'>"
	page += "<button>Logout Now!</button></a><br><br>"

	page += "</body></html>"

	res.send(page)
});

app.get('/deposit', function(req,res) {
    if(!req.session.username)
    {
		res.redirect("/");
    }

	let uname = req.session.username;

    getAccount(uname)
		.then(data => { 
			let i;
			let page = "<html>"
			page += "<body>"
			page += "<h1>Secure Banking Deposit Page</h1><br><br>"

			// start form
			page += "<form action='/deposit_success' method='POST'>"

			// drop down menu
			page += "<label for='account'>Choose an account </label>"
			page += "<select class='account' data-style='btn-info' name='account'>"
			for (i = 0; i < data.length; i++)
			{
				page += "<option value='" + data[i] + "'>Account " + data[i] + "</option>"
			}
			page += "</select><br><br>"

			// deposit user input
			page += "<label for='deposit'>Deposit between $10 and $10000   </label>"
			page += "<input type='number' id='deposit' name='deposit' value='0' min='10' max='10000' required>"
			page += "<input type='submit' value='Confirm'>"
			page += "</form>"

			// go to main page
			page += "<a href='/dashboard'>"
			page += "<button>Main Page</button> </a><br><br>"
			page += "<a href='/logout'>"
			page += "<button>Logout Now!</button></a><br><br>"

			page += "</body></html>"

			res.send(page)
		})
		.catch(err => console.error(err));
});

app.get('/withdraw', function(req,res) {
    if(!req.session.username)
    {
		res.redirect("/");
    }

	let uname = req.session.username;

    getAccount(uname)
		.then(data => { 
			let i;
			let page = "<html>"
			page += "<body>"
			page += "<h1>Secure Banking Withdraw Page</h1><br><br>"

			// start form
			page += "<form action='/withdraw_success' method='POST'>"

			// drop down menu
			page += "<label for='account'>Choose an account </label>"
			page += "<select class='account' data-style='btn-info' name='account'>"
			for (i = 0; i < data.length; i++)
			{
				page += "<option value='" + data[i] + "'>Account " + data[i] + "</option>"
			}
			page += "</select><br><br>"

			// withdraw user input
			page += "<label for='withdraw'>Withdraw between $10 and $10000   </label>"
			page += "<input type='number' id='withdraw' name='withdraw' value='0' min='10' max='10000' required>"
			page += "<input type='submit' value='Confirm'>"
			page += "</form>"

			// go to main page
			page += "<a href='/dashboard'>"
			page += "<button>Main Page</button> </a><br><br>"
			page += "<a href='/logout'>"
			page += "<button>Logout Now!</button></a><br><br>"

			page += "</body></html>"

			res.send(page)
		})
		.catch(err => console.error(err));
});

app.get('/transfer', function(req,res) {
	if(!req.session.username)
	{
		res.redirect("/");
	}

	let uname = req.session.username;
	
	getAccount(uname)
		.then(data => { 
			let i;
			let page = "<html>"
				page += "<body>"
				page += "<h1>Secure Banking Transfer Page</h1><br><br>"

				// form start
				page += "<form action='/transfer_success' method='POST'>"
				
				// drop down menu account 1
				page += "<label for='sender'>Choose an account to transfer from   </label>"
				page += "<select class='sender' data-style='btn-info' name='sender'>"
				for (i = 0; i < data.length; i++)
				{
					page += "<option value='" + data[i] + "'>Account " + data[i] + "</option>"
				}
				page += '</select><br><br>'

				// drop down menu account 2
				page += "<label for='receiver'>Choose an account to transfer to   </label>"
				page += "<select class='receiver' data-style='btn-info' name='receiver'>"
				for (i = 0; i < data.length; i++)
				{
					page += "<option value='" + data[i] + "'>Account " + data[i] + "</option>"
				}
				page += '</select><br><br>'

				// transfer user input
				page += "<label for='transfer'>Transfer between $1 and $10000   </label>"
				page += "<input type='number' id='transfer' value=0 name='transfer' min='1' max='10000' required>"
				page += "<input type='submit' value='Confirm'>"
				page += "</form>"

				// go to main page
				page += "<a href='/dashboard'>"
				page += "<button>Main Page</button> </a><br><br>"
				page += "<a href='/logout'>"
				page += "<button>Logout Now!</button></a><br><br>"

				// closing tags
				page += "</body></html>"

				res.send(page)
		})
		.catch(err => console.error(err));
});

app.post('/add_success', function(req,res) {
	if(!req.session.username)
	{
		res.redirect("/");
	}
	insertAccount(req.session.username, 0)
		.then(data => data)
		.catch(err => console.error(err));
	let page = "<html>"
		page += "<body>"
		page += "<h2>Successfully Added Account</h2><br><br>"
		
		page += "<a href='/add_accounts'>"
		page += "<button>Back</button> </a><br><br>"
		page += "<a href='/dashboard'>"
		page += "<button>Main Page</button> </a><br><br>"
		page += "<a href='/logout'>"
		page += "<button>Logout Now!</button></a><br><br>"

		page += "</body></html>"
		res.send(page);
});

app.post('/deposit_success', function(req,res) {
	if(!req.session.username)
	{
		res.redirect("/");
	}
	// Gather and sanitize user inputs
	let deposit = parseInt(xssFilters.inHTMLData(req.body.deposit));
	let acc = xssFilters.inHTMLData(req.body.account);
	getBalance(acc, req.session.username)
		.then(data => { 
			let current_balance = data;
			let new_balance = current_balance + deposit; // add deposit to current balance
			updateAccount(new_balance, acc, req.session.username)
				.then(data => data)
				.catch(err => console.error(err));
		})
		.catch(err => console.error(err));
	let page = "<html>"
		page += "<body>"
		page += "<h2>Successfully Deposited Amount</h2><br><br>"
		
		page += "<a href='/deposit'>"
		page += "<button>Back</button> </a><br><br>"
		page += "<a href='/dashboard'>"
		page += "<button>Main Page</button> </a><br><br>"
		page += "<a href='/logout'>"
		page += "<button>Logout Now!</button></a><br><br>"

		page += "</body></html>"
		res.send(page);
});

app.post('/withdraw_success', function(req,res) {
	if(!req.session.username)
	{
		res.redirect("/");
	}
	// Gather and sanitize user inputs
	let withdraw = parseInt(xssFilters.inHTMLData(req.body.withdraw));
	let acc = xssFilters.inHTMLData(req.body.account);
	getBalance(acc, req.session.username)
		.then(data => { 
			let current_balance = data;
			let new_balance = current_balance - withdraw; // subtract withdraw from current balance
			if (new_balance < 0)
			{
				let page = "<html>"
					page += "<body>"
					page += "<h2>Insufficient funds for withdraw amount</h2><br><br>"
					
					page += "<a href='/withdraw'>"
					page += "<button>Back</button> </a><br><br>"
					page += "<a href='/dashboard'>"
					page += "<button>Main Page</button> </a><br><br>"
					page += "<a href='/logout'>"
					page += "<button>Logout Now!</button></a><br><br>"

					page += "</body></html>"
					res.send(page);
			} else {
				updateAccount(new_balance, acc, req.session.username)
					.then(data => data)
					.catch(err => console.error(err));
				let page = "<html>"
					page += "<body>"
					page += "<h2>Successfully Withdrew Amount</h2><br><br>"
					
					page += "<a href='/withdraw'>"
					page += "<button>Back</button> </a><br><br>"
					page += "<a href='/dashboard'>"
					page += "<button>Main Page</button> </a><br><br>"
					page += "<a href='/logout'>"
					page += "<button>Logout Now!</button></a><br><br>"

					page += "</body></html>"
					res.send(page);
			}
		})
		.catch(err => console.error(err));
})

app.post('/transfer_success', function(req,res) {
	if(!req.session.username)
	{
		res.redirect("/");
	}
	// Gather and sanitize user inputs
	let transfer = parseInt(xssFilters.inHTMLData(req.body.transfer));
	let acc1 = xssFilters.inHTMLData(req.body.sender);
	let acc2 = xssFilters.inHTMLData(req.body.receiver);
	getBalance(acc1, req.session.username) // sender balance
		.then(data => { 
			let current_balance = data;
			let new_balance = current_balance - transfer; // subtract transfer from sender balance (withdraw)
			if (new_balance < 0)
			{
				let page = "<html>"
					page += "<body>"
					page += "<h2>Insufficient funds for transfer</h2><br><br>"
					
					page += "<a href='/transfer'>"
					page += "<button>Back</button> </a><br><br>"
					page += "<a href='/dashboard'>"
					page += "<button>Main Page</button> </a><br><br>"
					page += "<a href='/logout'>"
					page += "<button>Logout Now!</button></a><br><br>"

					page += "</body></html>"
					res.send(page);
			} else {
				updateAccount(new_balance, acc1, req.session.username)
					.then(data => data)
					.catch(err => console.error(err));
				getBalance(acc2, req.session.username) // reciever balance
					.then(data => { 
						let current_balance = data;
						let new_balance = current_balance + transfer; // add transfer to receiver balance (deposit)
						updateAccount(new_balance, acc2, req.session.username)
							.then(data => data)
							.catch(err => console.error(err));
						let page = "<html>"
							page += "<body>"
							page += "<h2>Successfully transfered the amount</h2><br><br>"
							
							page += "<a href='/transfer'>"
							page += "<button>Back</button> </a><br><br>"
							page += "<a href='/dashboard'>"
							page += "<button>Main Page</button> </a><br><br>"
							page += "<a href='/logout'>"
							page += "<button>Logout Now!</button></a><br><br>"

							page += "</body></html>"
							res.send(page);
					})
					.catch(err => console.error(err));
			}
		})
		.catch(err => console.error(err));
});

app.get('/logout', function(req, res){
    req.session.destroy();
    res.redirect('/');
});

app.listen(3000, () => {
    console.log('Server is running at port 3000');
});
