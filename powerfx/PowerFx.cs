using System.Globalization;
using System.Runtime.InteropServices.JavaScript;
using System.Runtime.Versioning;
using Microsoft.PowerFx;
using Microsoft.PowerFx.Types;

[SupportedOSPlatform("browser")]
public partial class PowerFx {
    [JSExport]
    internal static string Execute(String code) {
        var powerFxConfig = new PowerFxConfig(Features.PowerFxV1);
        var vals = new SymbolValues();
        var symbols = (SymbolTable)vals.SymbolTable;
        symbols.EnableMutationFunctions();
        powerFxConfig.SymbolTable = symbols;
        powerFxConfig.EnableSetFunction();
        var engine = new RecalcEngine(powerFxConfig);
        var result = engine.Eval(code, null, new ParserOptions() { AllowsSideEffects = true, Culture = new CultureInfo("en-us"), NumberIsFloat = true });
        if (result is StringValue stringValue) {
            return stringValue.Value;
        }
        if (result is NumberValue numberValue) {
            return numberValue.Value.ToString();
        } 
        string? value = result.ToString();
        return !string.IsNullOrEmpty(value) ? value : String.Empty;  
    }
}