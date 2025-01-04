---
layout: page
---

# Variables and Data Types

Welcome to the Variables and Data Types page! This section will introduce you to the fundamental building blocks of programming: variables and data types. Understanding these concepts is fundamental as they form the basis for all programming tasks. We'll use interactive Python examples to help you grasp these ideas.

## What Are Data Types?

In programming, data types are like different kinds of containers that hold various types of information. Just like in the real world, where you might use different containers for different items (e.g., a box for books, a jar for cookies), in programming, we use different data types to store different kinds of data.

### Real-World Examples

- **Algebra**: Think of data types like the different kinds of numbers you use in algebra. You have whole numbers (integers), fractions (floats), and even letters or symbols (strings).
- **Music**: In music, you have different types of notes and sounds. Each type of note (quarter note, half note) can be thought of as a different data type, each with its own properties.

## How Data Types Relate to Real-World Examples

### Algebra

In algebra, you often work with different types of numbers and symbols. Similarly, in programming, you use different data types to handle various kinds of data. For example, when solving an equation, you might use integers for whole numbers and floats for decimal numbers.

### Music

In music creation, you deal with different types of sounds and notes. Each type of note can be thought of as a different data type. For example, a quarter note might be an integer representing its duration, while a musical note's name (like "C" or "G") could be a string.

By understanding these basic data types, you'll be able to handle and manipulate data more effectively in your programming projects. Whether you're solving algebra problems, creating music, or building apps, knowing how to use variables and data types is a fundamental skill that will help you succeed.

## Scalar Types

### Integers

Integers are whole numbers that can be positive, negative, or zero. They are one of the most basic data types in programming and are used to perform arithmetic operations.

#### Example

In the example below, we add two integers together:

{% pyodide %}
a = 1
b = 2
c = a + b
c  # Output: 3
{% endpyodide %}

## Floats

Floats are numbers that have a decimal point. They are used to represent real numbers and perform arithmetic operations involving fractions.

### Example

In the example below, we add two floats together:

{% pyodide %}
x = 1.5
y = 2.3
z = x + y
z  # Output: 3.8
{% endpyodide %}

When you combine variables of type float and integers the result will be converted into a float

{% pyodide %}
x = 1
y = 2.3
z = x + y
z  # Output: 3.3
{% endpyodide %}

## Strings

Strings are sequences of characters used to represent text. They are another essential data type in programming and are used for handling and manipulating text data.

### Example

In the example below, we concatenate (join) two strings together:

{% pyodide %}
str1 = "Hello"
str2 = "World"
result = str1 + " " + str2
result  # Output: Hello World
{% endpyodide %}

## Booleans

Booleans represent one of two values: **True** or **False**. They are used in conditional statements and logical operations.

### Example

In the example below, we use a boolean to check a condition:

{% pyodide %}
is_sunny = True
if is_sunny:
    message = "It's a sunny day!"  
else:
    message = "It's not sunny today."
message # Output: It's a sunny day!
{% endpyodide %}

## Arrays

### Lists (1D Arrays)

Lists are ordered collections of items that can be of different data types. They are mutable, meaning their contents can be changed.

#### Example

##### Array of Same Type

In the example below, we create a list of integers:

{% pyodide %}
numbers = [1, 2, 3, 4, 5]
numbers  # Output: [1, 2, 3, 4, 5]
{% endpyodide %}

##### Updating a value

Lets look at how we can update a value. We use the square brackets and a integer value starting at **0** for the first item in the list.

{% pyodide %}
numbers = [1, 2, 3, 4, 5]
numbers[0] = -1
numbers  # Output: [-1, 2, 3, 4, 5]
{% endpyodide %}

##### Different data types

{% pyodide %}
items = [1, 2.2, "A", False, True]
items  # Output: [1, 2.2, 'A', False, True]
{% endpyodide %}

## Tuples (1D Arrays)
Tuples are ordered collections of items that can be of different data types. They are immutable, meaning their contents cannot be changed once created.

### Example
In the example below, we create a tuple of integers:

{% pyodide %}
coordinates = (10, 20)
coordinates # Output: (10, 20)
{% endpyodide %}

## Dictionaries (Associative Arrays)

Dictionaries are collections of key-value pairs. Each key is unique and is used to access its corresponding value.

### Example
In the example below, we create a dictionary with string keys and integer values:

{% pyodide %}
student_grades = {"Alice": 90, "Bob": 85, "Charlie": 92}
student_grades  # Output: {'Alice': 90, 'Bob': 85, 'Charlie': 92}
{% endpyodide %}

Dictionaries unlike arrays can be accessed using the string keys

{% pyodide %}
student_grades = {"Alice": 90, "Bob": 85, "Charlie": 92}
student_grades["Alice"]  # Output: 90
{% endpyodide %}

## Sets (Unordered Collections)
Sets are unordered collections of unique items. They are useful for storing items where duplicates are not allowed.

#### Example
In the example below, we create a set of integers:

{% pyodide %}
unique_numbers = {1, 2, 3, 4, 5}
unique_numbers  # Output: {1, 2, 3, 4, 5}
{% endpyodide %}

## Multi-Dimensional Arrays

### Example
In the example below, we create a 2D array (matrix) using a list of lists

{% pyodide %}
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
matrix
# Output:
# [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
{% endpyodide %}

The elements in the the multi dimensional array can be use multiple index

{% pyodide %}
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
matrix[2][2]
# Output:
# 9
{% endpyodide %}
