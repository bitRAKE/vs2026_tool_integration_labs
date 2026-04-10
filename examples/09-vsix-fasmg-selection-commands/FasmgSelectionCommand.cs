namespace FasmgSelectionCommands;

using System.Diagnostics;
using Microsoft.VisualStudio.Extensibility;
using Microsoft.VisualStudio.Extensibility.Commands;
using Microsoft.VisualStudio.Extensibility.Editor;
using Microsoft.VisualStudio.Extensibility.Shell;

internal abstract class FasmgSelectionCommand : Command
{
    protected static readonly ActivationConstraint FasmgEditorActive =
        ActivationConstraint.ClientContext(ClientContextKey.Shell.ActiveSelectionFileName, @"\.(fasm|finc)$");

    protected FasmgSelectionCommand(TraceSource traceSource)
    {
        this.TraceSource = traceSource;
    }

    protected TraceSource TraceSource { get; }

    protected async Task<SelectionExecutionResult?> ApplySelectionTransformAsync(
        IClientContext context,
        CancellationToken cancellationToken,
        Func<string, SelectionTransformResult> transform)
    {
        using ITextViewSnapshot? textView = await context.GetActiveTextViewAsync(cancellationToken);
        if (textView is null)
        {
            this.TraceSource.TraceInformation("There was no active text view when the command executed.");
            return null;
        }

        var selections = textView.Selections;
        var editedSelections = new List<SelectionEdit>();
        int nonEmptySelections = 0;
        int replacementCount = 0;

        for (int i = 0; i < selections.Count; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var selection = selections[i];
            if (selection.IsEmpty)
            {
                continue;
            }

            nonEmptySelections++;

            string originalText = selection.Extent.CopyToString();
            SelectionTransformResult result = transform(originalText);
            replacementCount += result.Replacements;

            if (!string.Equals(originalText, result.Text, StringComparison.Ordinal))
            {
                editedSelections.Add(new SelectionEdit(selection.Extent, result.Text));
            }
        }

        if (editedSelections.Count > 0)
        {
            await this.Extensibility.Editor().EditAsync(
                batch =>
                {
                    var editor = textView.Document.AsEditable(batch);
                    foreach (SelectionEdit edit in editedSelections)
                    {
                        editor.Replace(edit.Extent, edit.ReplacementText);
                    }
                },
                cancellationToken);
        }

        return new SelectionExecutionResult(nonEmptySelections, replacementCount, editedSelections.Count);
    }

    protected Task ShowMessageAsync(string message, CancellationToken cancellationToken)
        => this.Extensibility.Shell().ShowPromptAsync(message, PromptOptions.OK, cancellationToken);

    protected sealed class SelectionExecutionResult
    {
        public SelectionExecutionResult(int nonEmptySelections, int replacementCount, int changedSelections)
        {
            this.NonEmptySelections = nonEmptySelections;
            this.ReplacementCount = replacementCount;
            this.ChangedSelections = changedSelections;
        }

        public int NonEmptySelections { get; }

        public int ReplacementCount { get; }

        public int ChangedSelections { get; }
    }

    private sealed class SelectionEdit
    {
        public SelectionEdit(TextRange extent, string replacementText)
        {
            this.Extent = extent;
            this.ReplacementText = replacementText;
        }

        public TextRange Extent { get; }

        public string ReplacementText { get; }
    }
}
