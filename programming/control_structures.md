---
layout: page
---

# Control Structures

Welcome to the Control Structures page! This section will introduce you to the fundamental concepts of control structures in programming. Control structures are essential for directing the flow of a program and making decisions based on certain conditions. We'll use interactive Python examples to help you understand these concepts.

## What Are Control Structures?

Control structures are constructs that allow you to control the flow of execution in your programs. They enable you to make decisions, repeat actions, and manage the order in which statements are executed.

### Real-World Examples

- **Traffic Lights**: Think of control structures like traffic lights that control the flow of vehicles. They decide when cars should stop, go, or slow down.
- **Recipe Instructions**: In a recipe, you follow a set of instructions in a specific order. Control structures in programming work similarly by guiding the sequence of operations.

## Types of Control Structures

### Conditional Statements

Conditional statements allow you to execute certain code blocks based on specific conditions. The most common conditional statements are `if`, `elif`, and `else`.

#### Example: If Statement

In the example below, we use an `if` statement to check if a number is positive:

{% pyodide %}
number = 5
result = ""
if number > 0:
    result = "The number is positive"
result
{% endpyodide %}

This is similar to checking if a traffic light is green before proceeding.

#### Example: If-Else Statement

In the example below, we use an `if-else` statement to check if a number is positive or negative:

{% pyodide %}
number = -3
result = ""
if number > 0:
    result = "The number is positive"
else:
    result = "The number is negative"
result
{% endpyodide %}

This is like checking if a traffic light is green or red before deciding whether to go or stop.

#### Example: If-Elif-Else Statement

In the example below, we use an `if-elif-else` statement to check if a number is positive, negative, or zero:

{% pyodide %}
number = 0
result = ""
if number > 0:
    result = "The number is positive"
elif number < 0:
    result = "The number is negative"
else:
    result = "The number is zero"
result
{% endpyodide %}

This is like checking if a traffic light is green, red, or yellow before deciding whether to go, stop, or slow down.

### Loops

Loops allow you to repeat a block of code multiple times. The most common types of loops are `for` and `while` loops.

#### For Loops

For loops are used to iterate over a sequence (such as a list, tuple, or string) or other iterable objects.

##### Example 1: Iterating Over a Range

In the example below, we use a `for` loop to print numbers from 1 to 5:

{% pyodide %}
results = []
for i in range(1, 6):
    results.append(i)
results
{% endpyodide %}

##### Example 2: Iterating Over a List

In the example below, we use a `for` loop to iterate over a list of fruits:

{% pyodide %}
fruits = ["apple", "banana", "cherry"]
results = []
for fruit in fruits:
    results.append(fruit)
results
{% endpyodide %}

#### While Loops

While loops are used to repeat a block of code as long as a condition is true.

##### Example

In the example below, we use a `while` loop to print numbers from 1 to 5:

{% pyodide %}
results = []
i = 1
while i <= 5:
    results.append(i)
    i += 1
results
{% endpyodide %}

#### Do-While Loops

Python does not have a built-in `do-while` loop, but you can simulate it using a `while` loop with a `break` statement.

##### Example

In the example below, we simulate a `do-while` loop to print numbers from 1 to 5:

{% pyodide %}
results = []
i = 1
while True:
    results.append(i)
    i += 1
    if i > 5:
        break
results
{% endpyodide %}

This is like following a recipe that tells you to stir a mixture for a certain number of times.

## Practice questions

- [Draw Triangle](./problem_draw_triangle.md)