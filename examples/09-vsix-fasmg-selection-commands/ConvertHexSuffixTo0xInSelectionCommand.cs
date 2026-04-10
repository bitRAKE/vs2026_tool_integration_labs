namespace FasmgSelectionCommands;

using System.Diagnostics;
using Microsoft.VisualStudio.Extensibility;
using Microsoft.VisualStudio.Extensibility.Commands;

[VisualStudioContribution]
internal sealed class ConvertHexSuffixTo0xInSelectionCommand : FasmgSelectionCommand
{
    public ConvertHexSuffixTo0xInSelectionCommand(TraceSource traceSource)
        : base(traceSource)
    {
    }

    public override CommandConfiguration CommandConfiguration => new("%FasmgSelectionCommands.ConvertHex.DisplayName%")
    {
        EnabledWhen = FasmgEditorActive,
    };

    public override async Task ExecuteCommandAsync(IClientContext context, CancellationToken cancellationToken)
    {
        SelectionExecutionResult? result = await this.ApplySelectionTransformAsync(
            context,
            cancellationToken,
            FasmgSelectionTransforms.ConvertHexSuffixTo0xInSelection);

        if (result is null)
        {
            return;
        }

        if (result.NonEmptySelections == 0)
        {
            await this.ShowMessageAsync("Select one or more ranges before converting hex literals.", cancellationToken);
            return;
        }

        if (result.ReplacementCount == 0)
        {
            await this.ShowMessageAsync("No h-suffix hex literals were found outside comments or strings in the current selection.", cancellationToken);
        }
    }
}
