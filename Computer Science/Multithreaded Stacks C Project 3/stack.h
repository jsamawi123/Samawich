#pragma once
#include <stdlib.h>  // NULL

// Public type declarations:
typedef struct StackNode StackNode;  // Definition is private (this is called an incomplete
                                     //     type, or sometime called a forward definition)
typedef int    value_t;              // For simplicity, the stack will hold integers

// Public type definitions:
typedef struct
{
  StackNode * _top;     // The stack ADT (abstract data type) top and size
  unsigned    _size;
  pthread_mutex_t _mutex; //per stack
} Stack;

// Public function definitions:
void    push     ( Stack * stack, value_t data );
value_t pop      ( Stack * stack               );
int     isEmpty  ( Stack * stack               );

// Public object declarations:
extern const Stack EmptyStack;