// CPSC 121 Spring 2018 Project 1: Tweet Splitter
//
// Goal: Create a program to split tweets that are longer than 280 characters.
// Program splits tweet without splitting words or between chosen symbols (?!.).
// Single tweet will become multiple tweets ordered by (1/4), (2/4), ... (4/4). 
//
// System: Linux Ubuntu
//<<<<<<By James Samawi>>>>>>>>// main.cpp
#include <iostream>
#include <string> 
#include "twitter.hpp" //refer to prototypes
using namespace std;

// g++ -std=c++11 main.cpp twitter.cpp -o main
// ./main

int main()
{
  // get user input and call the appropriate functions for your program here
  
  //variable declaration...
  int split , option; //number of splits and option used for menu
  char confirm; //temporary variable to answer question
  string usr, msg; //declaration of username and the message
  
  string msgArray[100] = {}; //***array used the store message input by user***//
  
  // Start-up
  cout << "\t\tTwitter. It's what's happening." << endl								  
       << "See what’s happening in the world right now. Join Twitter today.\n\n"; //Title of program.
       
       
  
  // Ask for username (loops)...
  
  do /*OUTER LOOP*/
  {     
  cout << "Welcome to Twitter! \nPlease create a temporary Twitter username. (Ex: @john_Appleseed) ... " << endl; //loop starts here (if answered no)
  cout << "Note: spaces are prohibited" << endl << "@";
	   cin >> usr; //enter username
  cout << "Hi, " << "@" << usr << ". would you like to use this username? (Y/N)" << endl;
  
  cin  >> confirm; //user enters decision here
   
	while (confirm != 'y' && confirm != 'Y' && confirm != 'n' && confirm != 'N') { /*INNER LOOP*/
		//use AND condition, otherwise infinite loop
	
	cout << "Please enter the letter Y or N ... \n"; //This will LOOP until user enters Y or N
	cin >> confirm;
	
	}
	
  if (confirm == 'y' || confirm == 'Y') //Yes or no? IF yes, continue. LOOP if user enters no.
	cout << "username saved...\n\n"; //loop exit
		
  } while (confirm == 'n' || confirm == 'N'); //start from the beginning of the OUTER LOOP.
  
  
  
  // Menu loop starts here...
	do
	{  
	  cout << "What's on your mind?" << endl 
		   << "(1) Write a message..." << endl 
		   << "(2) Exit" << endl; //terminates program
			   
			cin  >> option; // either 1 or 2
			
		while (option != 1 && option != 2) { //just in case the user cannot read...
			
			cout << "Please enter the number 1 or 2 ...\n ";
			cin  >> option; //exit loop if user enters 1 or 2
				// caution: infinite loop if rebellious user enters a letter
		}
	  
	  switch (option)
		{
		  case 1: 
		   cout << "Okay! Start typing... \n\n";
		   cin.ignore(); //required
		   getline(cin, msg); //user entry is here
		   
		   //function calls have to be here, specifically...
			splitTweets(msg, msgArray, &split); //function call for splitting tweets
			displaySplitTweet(msgArray, usr, split); //function call for displaying tweets. Navigate to twitter.cpp for more info.
		   
			break;
			
		  case 2: //unnecessary, but for the sake of completion.
		  
			break; //terminates program
		  
		  default: ;
		}
	
	} while(option != 2); //do everything while option is NOT 2
	
	
  return 0; 
  
}//end of main
