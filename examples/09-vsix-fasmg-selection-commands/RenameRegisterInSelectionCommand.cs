namespace FasmgSelectionCommands;

using System.Diagnostics;
using Microsoft.VisualBasic;
using Microsoft.VisualStudio.Extensibility;
using Microsoft.VisualStudio.Extensibility.Commands;
using Microsoft.VisualStudio.Shell;

[VisualStudioContribution]
internal sealed class RenameRegisterInSelectionCommand : FasmgSelectionCommand
{
    public RenameRegisterInSelectionCommand(TraceSource traceSource)
        : base(traceSource)
    {
    }

    public override CommandConfiguration CommandConfiguration => new("%FasmgSelectionCommands.RenameRegister.DisplayName%")
    {
        EnabledWhen = FasmgEditorActive,
    };

    public override async Task ExecuteCommandAsync(IClientContext context, CancellationToken cancellationToken)
    {
        await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync(cancellationToken);

        string sourceRegister = Interaction.InputBox(
            "Rename which register inside the current selection?",
            "FASMG Register Rename",
            "eax").Trim();

        if (string.IsNullOrWhiteSpace(sourceRegister))
        {
            return;
        }

        string destinationRegister = Interaction.InputBox(
            "Replace it with which register?",
            "FASMG Register Rename",
            "r10d").Trim();

        if (string.IsNullOrWhiteSpace(destinationRegister))
        {
            return;
        }

        if (!FasmgSelectionTransforms.IsKnownRegister(sourceRegister))
        {
            await this.ShowMessageAsync(
                $"'{sourceRegister}' is not recognized as a supported register token.",
                cancellationToken);
            return;
        }

        if (!FasmgSelectionTransforms.IsKnownRegister(destinationRegister))
        {
            await this.ShowMessageAsync(
                $"'{destinationRegister}' is not recognized as a supported register token.",
                cancellationToken);
            return;
        }

        if (string.Equals(sourceRegister, destinationRegister, StringComparison.OrdinalIgnoreCase))
        {
            await this.ShowMessageAsync("Source and destination registers are the same.", cancellationToken);
            return;
        }

        SelectionExecutionResult? result = await this.ApplySelectionTransformAsync(
            context,
            cancellationToken,
            text => FasmgSelectionTransforms.RenameRegisterInSelection(text, sourceRegister, destinationRegister));

        if (result is null)
        {
            return;
        }

        if (result.NonEmptySelections == 0)
        {
            await this.ShowMessageAsync("Select one or more ranges before running the register rename command.", cancellationToken);
            return;
        }

        if (result.ReplacementCount == 0)
        {
            await this.ShowMessageAsync(
                $"No '{sourceRegister}' register tokens were found outside comments or strings in the current selection.",
                cancellationToken);
        }
    }
}
