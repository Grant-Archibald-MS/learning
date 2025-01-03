require 'liquid'
require 'securerandom'

module Jekyll
  class MathSolverBlock < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @id = "math-solver-#{rand(1000..9999)}"
    end

    def render(context)
      expression = super.strip
      
      <<~HTML
<div>
    <p>Select the type of question:</p>
    <label><input type="radio" name="questionType" value="integer" checked> Random Integer</label>
    <label><input type="radio" name="questionType" value="fraction"> Random Fraction</label>
    <label><input type="radio" name="questionType" value="decimal"> Random Decimal</label>
    <label><input type="radio" name="questionType" value="percent"> Percent Conversion</label>
    <button onclick="updateExpression('#{@id}')">Generate</button>
    <p>Enter your answer and press solve:</p>
    <textarea id="#{@id}-code" rows="10" cols="50" style="width: 100%;">#{expression}</textarea>
    <input type="text" id="#{@id}-answer" placeholder="Enter your answer here">
    <button id="#{@id}-solveButton" onclick="solveMath('#{@id}')" disabled>Solve</button>
    <p id="#{@id}-result"></p>
    <p>Prompt to use with Copilot:</p>
    <pre id="#{@id}-prompt"></pre>
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

    function generate_random_integer_expression() {
        const operators = ['+', '-', '*', '/'];
        const num_terms = 2;
        const terms = Array.from({ length: num_terms }, () => Math.floor(Math.random() * 21) - 10); // Generates integers between -10 and 10
        const expression = terms.join(` ${operators[Math.floor(Math.random() * operators.length)]} `);
        return expression;
    }

    function generate_random_fraction_expression() {
        const operators = ['+', '-', '*', '/'];
        const num_terms = 2;
        const terms = Array.from({ length: num_terms }, () => `${Math.floor(Math.random() * 9) + 1}/${Math.floor(Math.random() * 9) + 1}`);
        const expression = terms.join(` ${operators[Math.floor(Math.random() * operators.length)]} `);
        return expression;
    }

    function generate_random_decimal_expression() {
        const operators = ['+', '-', '*', '/'];
        const num_terms = 2;
        const terms = Array.from({ length: num_terms }, () => (Math.random() * 10).toFixed(2)); // Generates decimals between 0 and 10 with 2 decimal places
        const expression = terms.join(` ${operators[Math.floor(Math.random() * operators.length)]} `);
        return expression;
    }

    function generate_random_percent_conversion() {
        const type = Math.random() < 0.5 ? 'percent_to_decimal' : 'decimal_to_percent';
        if (type === 'percent_to_decimal') {
            const percent = Math.floor(Math.random() * 101); // Generates a percent between 0 and 100
            return `${percent}% to decimal`;
        } else {
            const decimal = (Math.random()).toFixed(2); // Generates a decimal between 0 and 1 with 2 decimal places
            return `${decimal} to percent`;
        }
    }

    function updateExpression(id) {
        const questionType = document.querySelector(`input[name="questionType"]:checked`).value;
        let expression = '';
        switch (questionType) {
            case 'integer':
                expression = generate_random_integer_expression();
                break;
            case 'fraction':
                expression = generate_random_fraction_expression();
                break;
            case 'decimal':
                expression = generate_random_decimal_expression();
                break;
            case 'percent':
                expression = generate_random_percent_conversion();
                break;
        }
        window.editors[id + '-code'].setValue(expression);
    }

    async function solveMath(id) {
        let editor = window.editors[id + '-code'];
        let code = editor.getValue();
        
        let userAnswer = document.getElementById(id + '-answer').value;
        let resultElement = document.getElementById(id + '-result');
        let promptElement = document.getElementById(id + '-prompt');

        const pythonCode = `
import re
import sympy as sp
from fractions import Fraction
import json

def preprocess_expression(expression):
    expression = expression.replace('/', ' / ')
    expression = re.sub(r'(?<![\\\\d)])-(\\\\d)', r'~\\\\1', expression)
    expression = re.sub(r'(\\\\d+)% of (\\\\d+)', r'(\\\\1 / 100) * \\\\2', expression)
    expression = re.sub(r'(\\\\d+\\\\.\\\\d+) to percent', r'(\\\\1 * 100)', expression)
    expression = re.sub(r'(\\\\d+)\\\\% to decimal', r'(\\\\1 * 0.01)', expression)
    return expression

def shunting_yard_algorithm(expression):
    precedence = {'+': 1, '-': 1, '*': 2, '/': 2, '^': 3, '~': 4}
    associativity = {'+': 'L', '-': 'L', '*': 'L', '/': 'L', '^': 'R', '~': 'R'}
    
    output_queue = []
    operator_stack = []
    
    tokens = re.findall(r'\\\\d+/\\\\d+|\\\\d+\\\\.\\\\d+|\\\\d+|[+\\\\-*/^()]|~\\\\d+', expression)
    
    for token in tokens:
        if re.match(r'\\\\d+/\\\\d+|\\\\d+\\\\.\\\\d+|\\\\d+|~\\\\d+', token):
            output_queue.append(token)
        elif token in precedence:
            while (operator_stack and operator_stack[-1] in precedence and
                   ((associativity[token] == 'L' and precedence[token] <= precedence[operator_stack[-1]]) or
                    (associativity[token] == 'R' and precedence[token] < precedence[operator_stack[-1]]))):
                output_queue.append(operator_stack.pop())
            operator_stack.append(token)
        elif token == '(':
            operator_stack.append(token)
        elif token == ')':
            while operator_stack and operator_stack[-1] != '(':
                output_queue.append(operator_stack.pop())
            operator_stack.pop()
    
    while operator_stack:
        output_queue.append(operator_stack.pop())
    
    return output_queue

def evaluate_rpn(rpn_expression):
    stack = []
    
    for token in rpn_expression:
        if token.startswith('~'):
            stack.append(-Fraction(token[1:]))
        elif re.match(r'\\\\d+\\\\.\\\\d+', token):
            stack.append(Fraction(token))
        elif re.match(r'\\\\d+', token):
            stack.append(Fraction(int(token)))
        elif token in {'+', '-', '*', '/', '^'}:
            b = stack.pop()
            a = stack.pop()
            if token == '+':
                stack.append(a + b)
            elif token == '-':
                stack.append(a - b)
            elif token == '*':
                stack.append(a * b)
            elif token == '/':
                stack.append(a / b)
            elif token == '^':
                stack.append(a ** b)
    
    return stack[0]

def calculate_expression(expression):
    try:
        expression = preprocess_expression(expression)
    except Exception as e:
        return json.dumps({"error": f"Preprocessing error: {str(e)}"})
    
    try:
        rpn_expression = shunting_yard_algorithm(expression)
    except Exception as e:
        return json.dumps({"expression": expression, "error": f"Shunting Yard Algorithm error: {str(e)}"})
    
    try:
        result = evaluate_rpn(rpn_expression)
    except Exception as e:
        return json.dumps({"error": f"RPN evaluation error: {str(e)}"})
    
    try:
        simplified = sp.simplify(result)
        if (isinstance(simplified, sp.Rational) and '/' not in expression):
            simplified_result = str(simplified.evalf()).rstrip('0').rstrip('.')
        else:
            simplified_result = str(simplified)
    except Exception as e:
        return json.dumps({"error": f"Simplification error: {str(e)}"})
    
    return json.dumps({
        "preprocessed_expression": expression,
        "rpn_expression": rpn_expression,
        "result": simplified_result
    })

expression = '${code}'
result = calculate_expression(expression)
result`;

        let result = await runPythonCode(pythonCode);
        if (result !== null) {
            let parsedResult = JSON.parse(result);
            if (parsedResult.error) {
                resultElement.textContent = "Error";
                promptElement.textContent = result;
            } else {
                let expected = parsedResult.result;
                if (expected === userAnswer) {
                    resultElement.textContent = "Correct!";
                    promptElement.textContent = "";
                } else {
                    resultElement.textContent = `Incorrect, expected ${expected}!`;
                    promptElement.textContent = `Explain the correct answer and the steps to solve it for the following expression. Do NOT use MathJax syntax for answers: 
    ${code} = ${expected}`;
                }
            }
        } else {
            resultElement.textContent = "Error evaluating expression.";
        }
    }
    </script>
</div>
      HTML
    end
  end
end

Liquid::Template.register_tag('math_solver', Jekyll::MathSolverBlock)