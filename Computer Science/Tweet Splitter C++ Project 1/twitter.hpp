//<<<<<<By James Samawi>>>>>>>>// twitter.hpp
#include <string>
using namespace std;

// function prototypes for splitTweets and displaySplitTweet here:

void splitTweets(string msg, string msgArray[], int *split);
void displaySplitTweet(string msgArray[], string usr, int split);

// Additional function prototypes:
int calcSplits(string message);
int findPunc(string message, int end);
