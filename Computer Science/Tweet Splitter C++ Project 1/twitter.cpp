//<<<<<<By James Samawi>>>>>>>>// twitter.cpp
#include <iostream>
#include <string>
#include "twitter.hpp" //refer to prototypes
using namespace std;

//  This file will contain four function implementations that are needed to process tweets.

int calcNumSplits(string msg) //This function will calculate the number of splits and return the value of split
{
   //algorithm for calculating splits here
    double splits;
    int newSplits;
    int max_len = 280; //Maximum length of the message
   
    splits = msg.length() / static_cast<double>(max_len); //Calculates number of splits and rounds up
    newSplits = splits;
    if (splits > newSplits)
        newSplits++;
       
    return newSplits; //Return value of split

} //end of int calcNumSplits


void splitTweets(string msg, string msgArray[], int *split) //This function splits the string message array 
{
	/* WE KNOW.....
	* .length() = Returns length of string (public member function )
	* .at = Gets character in string (public member function )
	* .substr = Generates substring (public member function )
	* .find_last_of = Find character in string from the end (public member function )
	*/// definitions from the official c++ website.
	
    *split = calcNumSplits(msg); //Splits before moving on..

    if (*split > 1) //Checks if split is greater than 1
        for (int i = 0; i <= *split; i++) 
        {
           //algorithm for splitting message here
           //be cautious, temperring with code may result in an out of range error
           
            unsigned int initial = 0; //unsigned for non-negative values
            unsigned int end = 279; //Declare the starting and ending val of tweet
           
            if (msg.length() < end)
            {
                end = msg.length() -1; //Decrement
                
            } else { //Fix where the split should take place
				
                end = findPunc(msg, end);
                
			       }
			     
            msgArray[i] = msg.substr(initial, end +1); //make a new substring from start to end 
            msg = msg.substr(end +1);
	
    } 
   else
        msgArray[0] = msg; //Store un-split tweet to message		
			
	
			
}//end of void splitTweets


int findPunc(string msg, int initial) //This function finds space and punctuation character using recursion
{
   
    char spot = msg[initial];
   
    if ((spot != '?') && (spot != '!') && (spot != '.') && (spot != ' ')) //Checks where Punctuation is at and returns
    {
        return findPunc(msg, (initial - 1)); //Recursion until reaches end
        
    } else {
        return initial;
	       }
	       
}//end of int findPunc 


void displaySplitTweet(string msgArray[], string usr, int split) //This function simply displays the tweet with a correction for Twitter syntax
{	
	if (split == 1) //1 split means it will display itself!
	{
		cout << "\n@" << usr << ": " << msgArray[0] << endl << endl;
	}
	else //display for tweets greater than 1 split
	{
		for(int i = 0; i < split; i++){ //*******important that is loop remains untouched**********//
			
            cout << "\n@" << usr << ": " << msgArray[i] << " " << "(" << i+1 << "/" << split << ")" << endl << endl;
            //start the loop at 0 in order to display msgArray[0] to the ith split, & add i + 1 becuase of this. (msgArray[0] will have (1/2) instead of (0/2) for example) 
            
		}
	
	}
}//end of void displaySplitTweet



