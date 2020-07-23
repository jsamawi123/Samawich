// OPERATING SYSTEMS FALL 2018 HOMEWORK 3: STACKS AND THREADS -BY JAMES SAMAWI
// SYSTEM: LINUX UBUNTU 18.04.3
// To run:  ./Build.sh stack
//          ./stack
#include <pthread.h> // pthread_t, pthread_create(), pthread_join
#include <stdint.h>  // int32_t, uintptr_t
#include <stdio.h>   // printf()
#include <stdlib.h>  // random_r(), srandom_r(), random_data (Thread friendly for POSIX compliant system)

#include "stack.h"


//Private types and objects definitions
typedef struct
{
  Stack    * stacks;      // array of stacks
  unsigned   stacksSize;  // number of stacks in the array
} SomethingReallyImportant_Parameters;



static void * somethingReallyImportant(void * args) //Private helper functions
{
  // Typecast parameters into something more understandable
  SomethingReallyImportant_Parameters * parameters = args;  // typecast into something more usable
  Stack * stacks      = parameters->stacks;
  unsigned stacksSize = parameters->stacksSize;

  // Seed for random generator with the address of a local stack object helping ensure each thread gets a unique seed
  struct random_data  randomNumberBuffer     = {0};
  char                randomNumberState[128] = {0};
  initstate_r( (uintptr_t)&randomNumberBuffer, randomNumberState, sizeof(randomNumberState), &randomNumberBuffer );

  // About two-thirds of the time push a random 12-bit number (0..4095) onto one of the stacks, and pop a value off
  // one of the stack about one-third of the time.
  int32_t theRandomNumber = 0;
  for (unsigned i = 0; i < 1000; ++i)
  {
    random_r( &randomNumberBuffer, &theRandomNumber );          // get the next random number
    Stack * stack = stacks + (theRandomNumber % stacksSize);    // pick one of the stacks

    if( theRandomNumber%3 == 0 )   pop ( stack );
    else                           push( stack, theRandomNumber % (1<<12) );
  }

  return NULL;
}



int main(void)
{
  // create and populate an array of stacks just so we can randomly intermix invoking operations on them
  Stack          arrayOfStacks[] = {EmptyStack, EmptyStack, EmptyStack, EmptyStack};
  unsigned const size            = sizeof(arrayOfStacks)/sizeof(*arrayOfStacks);

  // Create many threads all running concurrently.
  #define THREAD_COUNT 200u                                 // Change number of threads here
  pthread_t thread_ids[ THREAD_COUNT ] = {0};

  // do something really important that uses all those stacks
  // somethingReallyImportant(arrayOfStacks, size);
  SomethingReallyImportant_Parameters arguments = {arrayOfStacks, size};
  for( unsigned i = 0;  i != THREAD_COUNT;  ++i )   pthread_create( thread_ids+i, NULL, somethingReallyImportant, &arguments );

  // Wait for all threads to complete
  for( unsigned i = 0;  i != THREAD_COUNT;  ++i )   pthread_join( thread_ids[i], NULL );

  // Display each stack's size and its first 5 elements
  for( unsigned i = 0; i<size; ++i )
  {
    Stack * stack = & arrayOfStacks[i];
    printf("stack[%d] | size = %05d | first five numbers:  ", i, stack->_size);

    for(unsigned j = 0;  (j < 4) && (!isEmpty(stack));  ++j)   printf( "%5d, ", pop( stack ) );
    printf( "%5d\n", pop( stack ) );
  }

  printf("\nProgram completed successfully\n");
  return 0;
}
