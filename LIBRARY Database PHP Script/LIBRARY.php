<?php
// FILE STRUCTURES AND DATABASES: ASSIGNMENT 3
// JAMES SAMAWI 3/31/20

$conn = mysqli_connect('127.0.0.1', 'root', ''); // ENTER LOCALHOST PASS

if (!$conn) {
	
    die('Could not connect: '.mysqli_error($conn));
}

$sql = "DROP DATABASE LIBRARY"; //incase any preexisting ones
if (mysqli_query($conn, $sql)) {
    echo "Outdated database deleted successfully. ";
}

$sql = "CREATE DATABASE LIBRARY";

if(mysqli_query($conn, $sql)){
	
    echo "Database created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Database. " . mysqli_error($conn);
}

$dbName= "Library";
mysqli_select_db($conn, $dbName) or die("Unable to select database $dbName");
//this part is necessary.


//NOTE: Ordering matters. Tables are ordered such that no errors arise.

$publisher = "CREATE TABLE PUBLISHER (

    Name VARCHAR(30) PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL

)";

if(mysqli_query($conn, $publisher)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$book = "CREATE TABLE BOOK (

    Book_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(30) NOT NULL,
    Publisher_name VARCHAR(30) NOT NULL,
    FOREIGN KEY (Publisher_name) REFERENCES PUBLISHER(Name)

)";

if(mysqli_query($conn, $book)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$book_author = "CREATE TABLE BOOK_AUTHOR (

    Book_id INT(11) PRIMARY KEY,
    Author_name VARCHAR(30) NOT NULL,
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id)

)";

if(mysqli_query($conn, $book_author)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$library_branch = "CREATE TABLE LIBRARY_BRANCH (

    Branch_id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Branch_name VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL

)";

if(mysqli_query($conn, $library_branch)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$book_copies = "CREATE TABLE BOOK_COPIES (

    Book_id INT(11) NOT NULL,
    Branch_id INT(11) NOT NULL,
    No_of_copies int(11) NOT NULL,
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id),
    FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id)

)";

if(mysqli_query($conn, $book_copies)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$borrower = "CREATE TABLE BORROWER (

    Card_id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL

)";

if(mysqli_query($conn, $borrower)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}


$book_loans = "CREATE TABLE BOOK_LOANS (

    Book_id INT(11) NOT NULL,
    Branch_id INT(11) NOT NULL,
    Card_no INT(11) NOT NULL,
    Date_out Date NOT NULL,
    Due_date Date NOT NULL,
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id),
    FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id),
    FOREIGN KEY (Card_no) REFERENCES BORROWER(Card_id)

)";

if(mysqli_query($conn, $book_loans)){
	
    echo "Table created successfully. ";
	
} else {
    
	echo "ERROR: Could not create Table. " . mysqli_error($conn);
}

mysqli_close($conn);

?>