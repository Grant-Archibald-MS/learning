require 'liquid'
require 'securerandom'

module Jekyll
  class MathAnglesBlock < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @id = "math-angles-#{rand(1000..9999)}"
    end

    def render(context)
      code = super.strip
      <<~HTML
<style>
  .CodeMirror {
    border: 1px solid #eee;
    height: auto;
  }
  .CodeMirror-scroll {
    max-height: 200px;
  }
</style>
<div>
  <label><input type="radio" name="questionType" value="triangle" onclick="setQuestionType('#{@id}', 'triangle')"> Triangle</label>
  <label><input type="radio" name="questionType" value="isosceles" onclick="setQuestionType('#{@id}', 'isosceles')"> Isosceles Triangle</label>
  <label><input type="radio" name="questionType" value="straightLine" onclick="setQuestionType('#{@id}', 'straightLine')"> Angles on a Straight Line</label>
  <label><input type="radio" name="questionType" value="circle" onclick="setQuestionType('#{@id}', 'circle')"> Angles in a Circle</label>
</div>
<button id="#{@id}-generateButton" onclick="generateQuestion('#{@id}')">Generate</button>
<p id="#{@id}-question"></p>
<textarea id="#{@id}-code" rows="10" cols="50" style="width: 100%;">#{code}</textarea>
<input type="text" id="#{@id}-answer" placeholder="Enter your answer">
<button id="#{@id}-solveButton" onclick="solveProblem('#{@id}')" disabled>Solve</button>
<p id="#{@id}-result"></p>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/codemirror.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/codemirror.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/mode/javascript/javascript.min.js"></script>
<script src="https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function() {
    window.editors = window.editors || {};
    window.editors["#{@id}-code"] = CodeMirror.fromTextArea(document.getElementById('#{@id}-code'), {
      mode: 'javascript',
      lineNumbers: true
    });
  });

  async function loadPyodideAndPackages() {
    if (typeof window.pyodide === "undefined") {
      window.pyodide = await loadPyodide({
        indexURL: "https://cdn.jsdelivr.net/pyodide/v0.26.4/full/"
      });
      await window.pyodide.loadPackage("sympy");
      document.getElementById('#{@id}-solveButton').disabled = false;
    }
  }
  loadPyodideAndPackages();

  async function runPythonCode(code) {
    try {
      let result = await pyodide.runPythonAsync(code);
      return result;
    } catch (err) {
      return null;
    }
  }

  let questionType = '';

  function setQuestionType(id, type) {
    questionType = type;
  }

  function generateQuestion(id) {
    let questionElement = document.getElementById(id + '-question');
    let codeElement = window.editors[id + '-code'];
    let question, equation;

    switch(questionType) {
      case 'triangle':
        let angle1 = Math.floor(Math.random() * 90) + 1;
        let angle2 = Math.floor(Math.random() * (90 - angle1)) + 1;
        question = `Triangle: Given angles ${angle1}° and ${angle2}°, find the unknown angle x.`;
        equation = `${angle1} + ${angle2} + x = 180`;
        break;
      case 'isosceles':
        let angle = Math.floor(Math.random() * 90) + 1;
        question = `Isosceles Triangle: Given angle ${angle}°, find the unknown angle x.`;
        equation = `${angle} + 2*x = 180`;
        break;
      case 'straightLine':
        let outerAngle = Math.floor(Math.random() * 170) + 1;
        question = `Angles on a Straight Line: Given angle ${outerAngle}°, find the unknown angle x.`;
        equation = `x + ${outerAngle} = 180`;
        break;
      case 'circle':
        let angleA = Math.floor(Math.random() * 30) + 20;
        let angleB = Math.floor(Math.random() * 30) + 20;
        let angleC = Math.floor(Math.random() * 30) + 20;
        question = `Angles in a Circle: Given angles ${angleA}°, ${angleB}°, and ${angleC}°, find the unknown angle x.`;
        equation = `x + ${angleA} + ${angleB} + ${angleC} = 360`;
        break;
    }

    questionElement.textContent = question;
    codeElement.setValue(equation);
  }

  async function solveProblem(id) {
    let editor = window.editors[id + '-code'];
    let code = editor.getValue();
    
    let userAnswer = document.getElementById(id + '-answer').value;
    let resultElement = document.getElementById(id + '-result');

    const pythonCode = `
import sympy as sp
import json

def solve_problem(expression, user_answer):
    lhs, rhs = expression.split('=')

    lhs = sp.sympify(lhs)
    rhs = sp.sympify(rhs)

    variables = list(lhs.free_symbols.union(rhs.free_symbols))

    if len(variables) != 1:
        raise ValueError("Equation must involve exactly one variable.")

    variable = variables[0]

    simplified = lhs - rhs

    solution = sp.solve(simplified, variable)


    expected = f"{solution[0]:.2f}".rstrip('0').rstrip('.')
    
    # Calculate the difference
    difference = solution[0] - sp.sympify(user_answer)

    return json.dumps({"solution": str(expected), "difference": str(difference)})

expression = '${code}'
user_answer = '${userAnswer}'
result = solve_problem(expression, user_answer)
result`
            
      let result = await runPythonCode(pythonCode);
      if (result !== null) {
        let parsedResult = JSON.parse(result);
        if (parsedResult.error) {
          resultElement.textContent = "Error: " + parsedResult.error;
        } else {
          let expected = parsedResult.solution;
          let difference = parsedResult.difference;
          if (difference === '0') {
            resultElement.textContent = "Correct!";
          } else {
            resultElement.textContent = `Incorrect, expected ${expected}!`;
          }
        }
      } else {
        resultElement.textContent = "Error evaluating expression.";
      }
    }
  </script>
<div>
      HTML
    end
  end
end

Liquid::Template.register_tag('math_angles', Jekyll::MathAnglesBlock)