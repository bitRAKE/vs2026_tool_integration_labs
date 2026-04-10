#nullable enable

namespace FasmgSelectionCommands
{
    using System;
    using System.Collections.Generic;
    using System.Text;

    public sealed class SelectionTransformResult
    {
        public SelectionTransformResult(string text, int replacements)
        {
            this.Text = text ?? string.Empty;
            this.Replacements = replacements;
        }

        public string Text { get; private set; }

        public int Replacements { get; private set; }
    }

    public static class FasmgSelectionTransforms
    {
        private static readonly HashSet<string> KnownRegisters = CreateKnownRegisters();

        public static bool IsKnownRegister(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
            {
                return false;
            }

            return KnownRegisters.Contains(token.Trim());
        }

        public static SelectionTransformResult RenameRegisterInSelection(string text, string sourceRegister, string destinationRegister)
        {
            if (string.IsNullOrEmpty(text) || !IsKnownRegister(sourceRegister) || !IsKnownRegister(destinationRegister))
            {
                return new SelectionTransformResult(text ?? string.Empty, 0);
            }

            return TransformLexicalText(
                text,
                identifierTransform: token =>
                {
                    if (token.Equals(sourceRegister, StringComparison.OrdinalIgnoreCase))
                    {
                        return destinationRegister;
                    }

                    return null;
                },
                numberTransform: null);
        }

        public static SelectionTransformResult UppercaseRegistersInSelection(string text)
            => TransformRegisterCase(text, upper: true);

        public static SelectionTransformResult LowercaseRegistersInSelection(string text)
            => TransformRegisterCase(text, upper: false);

        public static SelectionTransformResult ConvertHexSuffixTo0xInSelection(string text)
        {
            if (string.IsNullOrEmpty(text))
            {
                return new SelectionTransformResult(text ?? string.Empty, 0);
            }

            return TransformLexicalText(
                text,
                identifierTransform: null,
                numberTransform: token =>
                {
                    if (!TryConvertHexSuffixToken(token, out string? converted))
                    {
                        return null;
                    }

                    return converted;
                });
        }

        private static SelectionTransformResult TransformRegisterCase(string text, bool upper)
        {
            if (string.IsNullOrEmpty(text))
            {
                return new SelectionTransformResult(text ?? string.Empty, 0);
            }

            return TransformLexicalText(
                text,
                identifierTransform: token =>
                {
                    if (!IsKnownRegister(token))
                    {
                        return null;
                    }

                    return upper ? token.ToUpperInvariant() : token.ToLowerInvariant();
                },
                numberTransform: null);
        }

        private static SelectionTransformResult TransformLexicalText(
            string text,
            Func<string, string?>? identifierTransform,
            Func<string, string?>? numberTransform)
        {
            StringBuilder builder = new StringBuilder(text.Length);
            int replacements = 0;
            int position = 0;

            while (position < text.Length)
            {
                char current = text[position];

                if (current == ';')
                {
                    AppendLineComment(text, builder, ref position);
                    continue;
                }

                if (current == '\'' || current == '"')
                {
                    AppendQuotedString(text, builder, ref position, current);
                    continue;
                }

                if (IsIdentifierStart(current))
                {
                    AppendTransformedIdentifier(text, builder, ref position, identifierTransform, ref replacements);
                    continue;
                }

                if (char.IsDigit(current))
                {
                    AppendTransformedNumber(text, builder, ref position, numberTransform, ref replacements);
                    continue;
                }

                builder.Append(current);
                position++;
            }

            return new SelectionTransformResult(builder.ToString(), replacements);
        }

        private static void AppendLineComment(string text, StringBuilder builder, ref int position)
        {
            while (position < text.Length)
            {
                char current = text[position];
                builder.Append(current);
                position++;

                if (current == '\n')
                {
                    break;
                }
            }
        }

        private static void AppendQuotedString(string text, StringBuilder builder, ref int position, char quote)
        {
            builder.Append(quote);
            position++;

            while (position < text.Length)
            {
                char current = text[position];
                builder.Append(current);
                position++;

                if (current != quote)
                {
                    continue;
                }

                if (position < text.Length && text[position] == quote)
                {
                    builder.Append(text[position]);
                    position++;
                    continue;
                }

                break;
            }
        }

        private static void AppendTransformedIdentifier(
            string text,
            StringBuilder builder,
            ref int position,
            Func<string, string?>? identifierTransform,
            ref int replacements)
        {
            int start = position;
            position++;

            while (position < text.Length && IsIdentifierPart(text[position]))
            {
                position++;
            }

            string token = text.Substring(start, position - start);
            if (identifierTransform != null)
            {
                string? replacement = identifierTransform(token);
                if (!string.IsNullOrEmpty(replacement) && !string.Equals(replacement, token, StringComparison.Ordinal))
                {
                    builder.Append(replacement);
                    replacements++;
                    return;
                }
            }

            builder.Append(token);
        }

        private static void AppendTransformedNumber(
            string text,
            StringBuilder builder,
            ref int position,
            Func<string, string?>? numberTransform,
            ref int replacements)
        {
            int start = position;
            position++;

            while (position < text.Length && IsNumberPart(text[position]))
            {
                position++;
            }

            string token = text.Substring(start, position - start);
            if (numberTransform != null)
            {
                string? replacement = numberTransform(token);
                if (!string.IsNullOrEmpty(replacement) && !string.Equals(replacement, token, StringComparison.Ordinal))
                {
                    builder.Append(replacement);
                    replacements++;
                    return;
                }
            }

            builder.Append(token);
        }

        private static bool TryConvertHexSuffixToken(string token, out string? converted)
        {
            converted = null;
            if (string.IsNullOrEmpty(token) || token.Length < 2)
            {
                return false;
            }

            char suffix = token[token.Length - 1];
            if (suffix != 'h' && suffix != 'H')
            {
                return false;
            }

            string body = token.Substring(0, token.Length - 1).Replace("'", string.Empty);
            if (body.Length == 0)
            {
                return false;
            }

            for (int i = 0; i < body.Length; i++)
            {
                if (!IsHexDigit(body[i]))
                {
                    return false;
                }
            }

            converted = "0x" + body.ToUpperInvariant();
            return true;
        }

        private static bool IsIdentifierStart(char value)
            => char.IsLetter(value) || value == '_' || value == '.' || value == '?' || value == '@' || value == '$' || value == '#';

        private static bool IsIdentifierPart(char value)
            => char.IsLetterOrDigit(value) || value == '_' || value == '.' || value == '?' || value == '@' || value == '$' || value == '#';

        private static bool IsNumberPart(char value)
            => char.IsLetterOrDigit(value) || value == '\'' || value == '_';

        private static bool IsHexDigit(char value)
            => (value >= '0' && value <= '9')
               || (value >= 'a' && value <= 'f')
               || (value >= 'A' && value <= 'F');

        private static HashSet<string> CreateKnownRegisters()
        {
            HashSet<string> registers = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "al", "ah", "ax", "eax", "rax",
                "bl", "bh", "bx", "ebx", "rbx",
                "cl", "ch", "cx", "ecx", "rcx",
                "dl", "dh", "dx", "edx", "rdx",
                "sil", "si", "esi", "rsi",
                "dil", "di", "edi", "rdi",
                "bpl", "bp", "ebp", "rbp",
                "spl", "sp", "esp", "rsp",
                "ip", "eip", "rip",
                "cs", "ds", "es", "fs", "gs", "ss",
                "flags", "eflags", "rflags",
                "mxcsr",
            };

            for (int i = 0; i <= 15; i++)
            {
                registers.Add("r" + i);
                registers.Add("r" + i + "b");
                registers.Add("r" + i + "w");
                registers.Add("r" + i + "d");
                registers.Add("xmm" + i);
                registers.Add("ymm" + i);
                registers.Add("zmm" + i);
                registers.Add("mm" + i);
                registers.Add("k" + i);
                registers.Add("cr" + i);
                registers.Add("dr" + i);
            }

            for (int i = 0; i <= 7; i++)
            {
                registers.Add("st" + i);
                registers.Add("tr" + i);
                registers.Add("tmm" + i);
            }

            return registers;
        }
    }
}
