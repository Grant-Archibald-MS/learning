require 'liquid'
require 'securerandom'

module Jekyll
  class MathProblemsBlock < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @id = "math-problems-#{rand(1000..9999)}"
    end

    def render(context)
      expression = super.strip
      
      <<~HTML
<div>
    <p>Select the type of problem:</p>
    <label><input type="radio" name="problemType" value="ratio" checked> Ratio</label>
    <label><input type="radio" name="problemType" value="proportion"> Proportion</label>
    <label><input type="radio" name="problemType" value="percent"> Percent</label>
    <label><input type="radio" name="problemType" value="linear_equation"> Linear Equation</label>
    <button onclick="generateProblem('#{@id}')">Generate</button>
    <p id="#{@id}-question"></p>
    <p>Enter your answer and press solve:</p>
    <textarea id="#{@id}-code" rows="10" cols="50" style="width: 100%;"></textarea>
    <input type="text" id="#{@id}-answer" placeholder="Enter your answer here">
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

    function generate_ratio_problem() {
        const flour = Math.floor(Math.random() * 10) + 1;
        const sugar = Math.floor(Math.random() * 10) + 1;
        const new_flour = flour * (Math.floor(Math.random() * 5) + 1);
        const question = `A recipe requires ${flour} cups of flour for every ${sugar} cups of sugar. If you want to make a batch using ${new_flour} cups of flour, how many cups of sugar do you need?`;
        const equation = `(${flour} / ${sugar}) = (${new_flour} / x)`;
        return { question, equation };
    }

    function generate_proportion_problem() {
        const distance = Math.floor(Math.random() * 200) + 50;
        const time = Math.floor(Math.random() * 5) + 1;
        const new_time = time + Math.floor(Math.random() * 5) + 1;
        const question = `If a car travels ${distance} miles in ${time} hours, how far will it travel in ${new_time} hours at the same speed?`;
        const equation = `(${distance} / ${time}) = (x / ${new_time})`;
        return { question, equation };
    }

    function generate_percent_problem() {
        const original_price = Math.floor(Math.random() * 100) + 20;
        const discount = Math.floor(Math.random() * 50) + 10;
        const question = `A store is having a ${discount}% off sale on a jacket that originally costs $${original_price}. What is the sale price of the jacket?`;
        const equation = `x = ${original_price} - (${discount} / 100) * ${original_price}`;
        return { question, equation };
    }

    function generate_linear_equation_problem() {
        const a = Math.floor(Math.random() * 10) + 1;
        const b = Math.floor(Math.random() * 20) - 10;
        const c = Math.floor(Math.random() * 50) + 10;
        const question = `Solve for x: ${a}x + ${b} = ${c}`;
        const equation = `${a} * x + ${b} = ${c}`;
        return { question, equation };
    }

    function generateProblem(id) {
        const problemType = document.querySelector(`input[name="problemType"]:checked`).value;
        let problem = {};
        switch (problemType) {
            case 'ratio':
                problem = generate_ratio_problem();
                break;
            case 'proportion':
                problem = generate_proportion_problem();
                break;
            case 'percent':
                problem = generate_percent_problem();
                break;
            case 'linear_equation':
                problem = generate_linear_equation_problem();
                break;
        }
        document.getElementById(id + '-question').textContent = problem.question;
        window.editors[id + '-code'].setValue(problem.equation);
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
    
    # Calculate the difference
    difference = solution[0] - sp.sympify(user_answer)
    
    return json.dumps({"solution": str(solution[0]), "difference": str(difference)})

expression = '${code}'
user_answer = '${userAnswer}'
result = solve_problem(expression, user_answer)
result`;
        
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
</div>
      HTML
    end
  end
end

Liquid::Template.register_tag('math_problems', Jekyll::MathProblemsBlock)