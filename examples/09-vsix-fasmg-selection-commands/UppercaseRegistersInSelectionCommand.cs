namespace FasmgSelectionCommands;

using System.Diagnostics;
using Microsoft.VisualStudio.Extensibility;
using Microsoft.VisualStudio.Extensibility.Commands;

[VisualStudioContribution]
internal sealed class UppercaseRegistersInSelectionCommand : FasmgSelectionCommand
{
    public UppercaseRegistersInSelectionCommand(TraceSource traceSource)
        : base(traceSource)
    {
    }

    public override CommandConfiguration CommandConfiguration => new("%FasmgSelectionCommands.UppercaseRegisters.DisplayName%")
    {
        EnabledWhen = FasmgEditorActive,
    };

    public override async Task ExecuteCommandAsync(IClientContext context, CancellationToken cancellationToken)
    {
        SelectionExecutionResult? result = await this.ApplySelectionTransformAsync(
            context,
            cancellationToken,
            FasmgSelectionTransforms.UppercaseRegistersInSelection);

        if (result is null)
        {
            return;
        }

        if (result.NonEmptySelections == 0)
        {
            await this.ShowMessageAsync("Select one or more ranges before uppercasing registers.", cancellationToken);
            return;
        }

        if (result.ReplacementCount == 0)
        {
            await this.ShowMessageAsync("No register tokens were found outside comments or strings in the current selection.", cancellationToken);
        }
    }
}
