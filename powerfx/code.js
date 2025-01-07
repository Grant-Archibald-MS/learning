// Set up the .NET WebAssembly runtime
import { dotnet } from '/bin/Release/net9.0/wwwroot/_framework/dotnet.js'

// Get exported methods from the .NET assembly
const { getAssemblyExports, getConfig } = await dotnet
    .withDiagnosticTracing(false)
    .create();

const config = getConfig();
const exports = await getAssemblyExports(config.mainAssemblyName);

const result = exports.PowerFx.Execute("1 + 1");

// Display the result of the Power Fx
document.getElementById("out").innerHTML = `Result: ${result}`;