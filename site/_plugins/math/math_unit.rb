require 'liquid'
require 'securerandom'

module Jekyll
  class MathUnitsBlock < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @id = "math-units-#{rand(1000..9999)}"
    end

    def render(context)
      expression = super.strip
      
      <<~HTML
<div>
    <p>Select the type of problem:</p>
    <label><input type="radio" name="problemType" value="length" checked> Length</label>
    <label><input type="radio" name="problemType" value="weight"> Weight</label>
    <label><input type="radio" name="problemType" value="volume"> Volume</label>
    <label><input type="radio" name="problemType" value="temperature"> Temperature</label>
    <label><input type="radio" name="problemType" value="time"> Time</label>
    <label><input type="radio" name="problemType" value="speed"> Speed</label>
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

    function generate_unit_problem(units) {
        const choice = units[Math.floor(Math.random() * units.length)]
        const from_unit = choice.split('_')[0];
        const to_unit = choice.split('_')[1];
        const conversion = convert(from_unit, to_unit)

        const value = (Math.random() * 100).toFixed(0);
        const question = `Convert ${value} ${from_unit} to ${to_unit}. Assume conversion factor ${conversion}`;
        var equation = ''
        if (conversion.indexOf('v') >= 0)
            equation = 'x = ' + conversion.replace('v', value)
        else
            equation = 'x = ' + conversion + ' * ' + value
        return { question, equation };
    }

    function generate_length_problem() {
        return generate_unit_problem([
            'mm_cm', 'cm_mm', 
            'cm_m', 'm_cm',
            'm_km', 'km_m', 
            'in_ft', 'ft_in',
            'ft_yd', 'yd_ft',
            'yd_mi', 'mi_yd'
        ]);
    }

    function generate_weight_problem() {
        return generate_unit_problem([
            'mg_g', 'g_mg',
            'g_kg', 'kg_g',
            'ml_l', 'l_ml',
            'l_m³', 'm³_l',
        ]);
    }

    function generate_volume_problem() {
        return generate_unit_problem([
            'ml_l', 'l_ml',
            'l_m³', 'm³_l',
            'tsp_tbsp', 'tbsp_tsp',
            'tbsp_fl oz', 'fl oz_tbsp',
            'fl oz_c', 'c_fl oz',
            'c_pt', 'pt_c',
            'pt_qt', 'qt_pt',
            'qt_gal', 'gal_qt'
        ])   
    }

    function generate_temperature_problem() {
        return generate_unit_problem([
                '°C_°F', '°F_°C',
                '°C_K', 'K_°C'
            ]);
    }

    function generate_time_problem() {
        return generate_unit_problem([
            's_min', 'min_s',
            'min_h', 'h_min',
            'h_d', 'd_h',
            'd_wk', 'wk_d',
            'wk_mo', 'mo_wk',
            'mo_yr', 'yr_mo'
        ]);
    }

    function generate_speed_problem() {
        return generate_unit_problem([
            'm/s_km/h', 'km/h_m/s',
            'mph_ft/s', 'ft/s_mph',
            'mph_km/h', 'km/h_mph'
        ]);
    }

    function generateProblem(id) {
        const problemType = document.querySelector(`input[name="problemType"]:checked`).value;
        let problem = {};
        switch (problemType) {
            case 'length':
                problem = generate_length_problem();
                break;
            case 'weight':
                problem = generate_weight_problem();
                break;
            case 'volume':
                problem = generate_volume_problem();
                break;
            case 'temperature':
                problem = generate_temperature_problem();
                break;
            case 'time':
                problem = generate_time_problem();
                break;
            case 'speed':
                problem = generate_speed_problem();
                break;
        }
        document.getElementById(id + '-question').textContent = problem.question;
        window.editors[id + '-code'].setValue(problem.equation);
    }

    function convert(from_unit, to_unit) {
        const conversions = {
            'mm_cm': '0.1', 'cm_mm': '10',
            'cm_m': '0.01', 'm_cm': '100',
            'm_km': '0.001', 'km_m': '1000',
            'in_ft': '1/12', 'ft_in': '12',
            'ft_yd': '1/3', 'yd_ft': '3',
            'yd_mi': '1/1760', 'mi_yd': '1760',
            'mg_g': '0.001', 'g_mg': '1000',
            'g_kg': '0.001', 'kg_g': '1000',
            'ml_l': '0.001', 'l_ml': '1000',
            'l_m³': '0.001', 'm³_l': '1000',
            'tsp_tbsp': '1/3', 'tbsp_tsp': '3',
            'tbsp_fl oz': '1/2', 'fl oz_tbsp': '2',
            'fl oz_c': '1/8', 'c_fl oz': '8',
            'c_pt': '1/2', 'pt_c': '2',
            'pt_qt': '1/2', 'qt_pt': '2',
            'qt_gal': '1/4', 'gal_qt': '4',
            '°C_°F': 'v * 9/5 + 32', '°F_°C': '(v - 32) * 5/9',
            '°C_K': 'v + 273.15', 'K_°C': 'v - 273.15',
            's_min': '1/60', 'min_s': '60',
            'min_h': '1/60', 'h_min': '60',
            'h_d': '1/24', 'd_h': '24',
            'd_wk': '1/7', 'wk_d': '7',
            'wk_mo': '1/4.345', 'mo_wk': '4.345',
            'mo_yr': '1/12', 'yr_mo': '12',
            'm/s_km/h': '3.6', 'km/h_m/s': '1/3.6',
            'mph_ft/s': '1.467', 'ft/s_mph': '1/1.467',
            'mph_km/h': '1.60934', 'km/h_mph': '1/1.60934'
        };

        const key = `${from_unit}_${to_unit}`;
        if (conversions.hasOwnProperty(key)) {
            return conversions[key];
        } else {
            throw new Error("Conversion not supported.");
        }
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
    
Liquid::Template.register_tag('math_units', Jekyll::MathUnitsBlock)