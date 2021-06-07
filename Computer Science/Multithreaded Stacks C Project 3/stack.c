#include <stdlib.h>  // NULL, malloc(), free()
#include <pthread.h>
#include <stdio.h>   // printf()
#include "stack.h"

//Public types and objects definitions:
const Stack EmptyStack = {NULL, 0, PTHREAD_MUTEX_INITIALIZER};

struct StackNode
{
  value_t            _data;
  struct StackNode * _next;
};



// Public functions definitions:
void push( Stack * stack, value_t data )
{
  // provision memory for a new node
  StackNode * newNode = malloc( sizeof(StackNode) );

  // populate the new node with data
  newNode->_data = data;

    pthread_mutex_lock(&stack->_mutex); // Critical section starts here (stack)

  // link the new node onto the top of the stack and advance the stack top
  newNode->_next = stack->_top;
  stack->_top    = newNode;

  // maintain stack size
  ++stack->_size;
    pthread_mutex_unlock(&stack->_mutex); // Critical section ends here
}



value_t pop( Stack * stack )
{
    pthread_mutex_lock(&stack->_mutex); // Critical section starts here (stack)

  // What to do if asked to return data from an empty stack?
  if( isEmpty( stack ) ) // is empty?
  {
     pthread_mutex_unlock(&stack->_mutex);      // Critical section ends here <option 1>
    return (value_t)0;
  }
    pthread_mutex_unlock(&stack->_mutex);       // Critical section ends here <option 2>

  pthread_mutex_lock(&stack->_mutex); // Critical section starts here (stack)
  // advance the top of the stack to the next element
  StackNode * temp = stack->_top;
  stack->_top      = stack->_top->_next;

  // maintain stack size
  --stack->_size;
    pthread_mutex_unlock(&stack->_mutex); // Critical section ends here

  // hold a copy of the data at the top of the stack
  value_t data = temp->_data;

  // release the popped node
  free( temp );

  // return the requested data
  return data;
}



int isEmpty( Stack * stack)
{
    return stack->_top == NULL;
}
