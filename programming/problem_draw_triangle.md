---
layout: page
---

# Draw Triangle

Lets start off by looking at how we can take what we learned about data types to return an array of strings that represent a triangle. The simplest case could be  

```python
results = []
results.append("  *")
results.append(" ***")
results.append("*****")
results
```

While this works, what if we want the size of the triangle when there are 4, 5 or 6 lines? To solve for these different cases looking at [loops](./control_structures.md) and using [variables](./README.md) for the number of spaces and stars could be a solution that easily allows the code to handle different sizes of triangles.

{% python_problem %}
  *
 ***
*****
{% endpython_problem %}
