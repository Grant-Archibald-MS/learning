module Jekyll
    class PythonProblemTag < Liquid::Block
      def initialize(tag_name, text, tokens)
        super
        @id = "python-problem-#{rand(1000..9999)}"
      end
  
      def render(context)
        code = super
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
<p>This is the expected result:
It should match the actual result.</p>
<pre>#{code}</pre>
<textarea id="#{@id}-code" rows="10" cols="50" style="width: 100%;">
results = []
results.append("Your answer")
results
</textarea>
<button id="#{@id}-runButton" onclick="runPythonProblem('#{@id}')" disabled>Run</button>
<pre id="#{@id}-output"></pre>
<pre id="#{@id}-mismatch" style="color: red;"></pre>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/codemirror.min.css">
<script src="https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/codemirror.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/6.65.7/mode/python/python.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    async function loadPyodideAndPackages() {
        if (typeof window.pyodide === "undefined") {
        window.editors = [];
        window.pyodide = await loadPyodide({
            indexURL: "https://cdn.jsdelivr.net/pyodide/v0.26.4/full/"
        });
        }
        window.editors["#{@id}-code"] = CodeMirror.fromTextArea(document.getElementById('#{@id}-code'), {
        mode: 'python',
        lineNumbers: true
        });
        document.getElementById('#{@id}-runButton').disabled = false;
    }
    loadPyodideAndPackages();

    if (typeof window.runPythonProblem === "undefined") {
        let outputElement = document.getElementById('#{@id}-output');
        let mismatchElement = document.getElementById('#{@id}-mismatch');
        outputElement.innerText = ''
        mismatchElement.innerText = ''

        window.runPythonProblem = async function runPython(id) {
        let editor = window.editors['#{@id}-code'];
        let code = editor.getValue();
        
        let expectedResult = `#{code}`;
        try {
            let result = await pyodide.runPythonAsync(code);
            let json = result.toJSON();

            var text = ''
            json.forEach( (line) => {
                if(text.length > 0 ) {
                    text += "\\n"
                }
                text += line
            })

            outputElement.textContent = text;
            compareResults(expectedResult, json, mismatchElement);
        } catch (err) {
            outputElement.textContent = err;
        }
        }
    }

    function compareResults(expected, actualLines, mismatchElement) {
        let expectedLines = expected.split("\\n");
        expectedLines.shift(); // Remove the first blank line
        if (expectedLines.length !== actualLines.length) {
            displayMismatch(expectedLines, actualLines, mismatchElement);
            return;
        }
        for (let i = 0; i < expectedLines.length; i++) {
            if (expectedLines[i] !== actualLines[i]) {
                displayMismatch(expectedLines, actualLines, mismatchElement);
                return;
            }
        }
        mismatchElement.textContent = "Correct";
    }

    function displayMismatch(expectedLines, actualLines, mismatchElement) {
        let mismatchedLines = expectedLines.map((line, index) => {
        return { expected: line, actual: actualLines[index] || "" };
        }).filter(line => line.expected !== line.actual);

        if (mismatchedLines.length == 0) {
            mismatchElement.textContent = "Correct"
            return
        }

        let message = `${mismatchedLines.length} lines do not match:\\n`;
        mismatchedLines.forEach((line, index) => {
        message += `Line ${index + 1}:\\nExpected: ${line.expected}\\nActual: ${line.actual}\\n`;
        });
        mismatchElement.innerHTML = message.replace(/\\n/g, "<br>");
    }
})
</script>
        HTML
      end
    end
  end
  
  Liquid::Template.register_tag('python_problem', Jekyll::PythonProblemTag)