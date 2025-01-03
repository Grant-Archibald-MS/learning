require 'liquid'
require 'securerandom'

module Jekyll
  class MathShapesBlock < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @id = "math-shapes-#{rand(1000..9999)}"
    end

    def render(context)
      expression = super.strip
      
      <<~HTML
<div>
    <p>Select the type of question:</p>
    <label><input type="radio" name="questionType" value="rectangle" checked> Rectangle Perimeter</label>
    <label><input type="radio" name="questionType" value="triangle"> Triangle Area</label>
    <label><input type="radio" name="questionType" value="cube"> Cube Volume</label>
    <label><input type="radio" name="questionType" value="circle"> Circle Circumference</label>
    <button onclick="updateExpression('#{@id}')">Generate</button>
    <p>Question:</p>
    <p id="#{@id}-questiontext"></p>
    <p>Enter your answer and press solve:</p>
    <div>
    <textarea id="#{@id}-code" rows="10" cols="50" style="width: 100%;">#{expression}</textarea>
    </div>
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

    function generate_random_value(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function generate_rectangle_perimeter() {
        const length = generate_random_value(1, 20);
        const width = generate_random_value(1, 20);
        return {
            word_problem: `Calculate the perimeter of a rectangle with length ${length} cm and width ${width} cm.`,
            expression: `2 * (length + width)`,
            values: { length: length, width: width }
        };
    }

    function generate_triangle_area() {
        const base = generate_random_value(1, 20);
        const height = generate_random_value(1, 20);
        return {
            word_problem: `Find the area of a triangle with base ${base} cm and height ${height} cm.`,
            expression: `0.5 * base * height`,
            values: { base: base, height: height }
        };
    }

    function generate_cube_volume() {
        const side = generate_random_value(1, 20);
        return {
            word_problem: `Determine the volume of a cube with side length ${side} cm.`,
            expression: `side^3`,
            values: { side: side }
        };
    }

    function generate_circle_circumference() {
        const radius = generate_random_value(1, 20);
        return {
            word_problem: `What is the circumference of a circle with radius ${radius} cm?`,
            expression: `2 * pi * radius`,
            values: { radius: radius }
        };
    }

    function generate_quadrilateral_angles() {
        return {
            word_problem: 'Calculate the sum of the interior angles of a quadrilateral.',
            expression: '360',
            values: {}
        };
    }

    function updateExpression(id) {
        const questionType = document.querySelector(`input[name="questionType"]:checked`).value;
        let problem = {};
        switch (questionType) {
            case 'rectangle':
                problem = generate_rectangle_perimeter();
                break;
            case 'triangle':
                problem = generate_triangle_area();
                break;
            case 'cube':
                problem = generate_cube_volume();
                break;
            case 'circle':
                problem = generate_circle_circumference();
                break;
            case 'quadrilateral':
                problem = generate_quadrilateral_angles();
                break;
        }
        document.getElementById(id + '-questiontext').textContent = problem.word_problem;
        window.editors[id + '-code'].setValue(problem.expression);
        document.getElementById(id + '-result').textContent = '';
        document.getElementById(id + '-result').values = JSON.stringify(problem.values);
    }

    async function solveMath(id) {
        let editor = window.editors[id + '-code'];
        let code = editor.getValue();
        
        let userAnswer = document.getElementById(id + '-answer').value;
        let resultElement = document.getElementById(id + '-result');
        let promptElement = document.getElementById(id + '-prompt');
        let values = JSON.parse(resultElement.values);

        const pythonCode = `
import sympy as sp

length, width, base, height, side, radius = sp.symbols('length width base height side radius')
expression = sp.sympify('${code}')
result = expression.evalf(subs=${JSON.stringify(values)})
str(result).rstrip('0').rstrip('.')`;

        let result = await runPythonCode(pythonCode);
        if (result !== null) {
            let expected = result;
            if (expected == userAnswer) {
                resultElement.textContent = "Correct!";
                promptElement.textContent = "";
            } else {
                resultElement.textContent = `Incorrect, expected ${expected}!`;
                promptElement.textContent = `Explain the correct answer and the steps to solve it for the following expression. Do NOT use MathJax syntax for answers: 
    ${code} = ${expected}
    ${resultElement.values}`;
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

Liquid::Template.register_tag('math_shapes', Jekyll::MathShapesBlock)