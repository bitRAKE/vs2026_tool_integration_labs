namespace FasmgSelectionCommands;

using Microsoft.VisualStudio.Extensibility;
using Microsoft.VisualStudio.Extensibility.Commands;

internal static class FasmgSelectionCommandConfiguration
{
    [VisualStudioContribution]
    public static MenuConfiguration FasmgUtilitiesMenu => new("%FasmgSelectionCommands.Menu.DisplayName%")
    {
        Placements =
        [
            CommandPlacement.KnownPlacements.ExtensionsMenu.WithPriority(0x0200),
        ],
        Children =
        [
            MenuChild.Command<RenameRegisterInSelectionCommand>(),
            MenuChild.Separator,
            MenuChild.Command<UppercaseRegistersInSelectionCommand>(),
            MenuChild.Command<LowercaseRegistersInSelectionCommand>(),
            MenuChild.Separator,
            MenuChild.Command<ConvertHexSuffixTo0xInSelectionCommand>(),
        ],
    };
}
