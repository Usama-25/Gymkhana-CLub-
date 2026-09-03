using System;
using System.Text.RegularExpressions;

/// <summary>
/// ISBN-13 (EAN-13) validation, formatting, and conversion utilities.
/// Spec: https://www.isbn-international.org/content/what-isbn
/// </summary>
public static class ISBN13Helper
{
    // Strip hyphens and spaces → clean 13-digit string
    public static string Normalise(string isbn)
    {
        return isbn == null ? "" : Regex.Replace(isbn, @"[\s\-]", "");
    }

    /// <summary>Validate ISBN-13 check digit (modulo-10, weights 1 and 3).</summary>
    public static bool IsValid(string isbn)
    {
        string clean = Normalise(isbn);
        if (clean.Length != 13 || !Regex.IsMatch(clean, @"^\d{13}$")) return false;
        if (!clean.StartsWith("978") && !clean.StartsWith("979")) return false;

        int sum = 0;
        for (int i = 0; i < 12; i++)
            sum += (int)char.GetNumericValue(clean[i]) * (i % 2 == 0 ? 1 : 3);

        int check = (10 - (sum % 10)) % 10;
        return check == (int)char.GetNumericValue(clean[12]);
    }

    /// <summary>Calculate correct check digit for a 12-digit ISBN prefix.</summary>
    public static int CalculateCheckDigit(string first12)
    {
        string clean = Normalise(first12);
        if (clean.Length != 12 || !Regex.IsMatch(clean, @"^\d{12}$"))
            throw new ArgumentException("Input must be exactly 12 digits.");
        int sum = 0;
        for (int i = 0; i < 12; i++)
            sum += (int)char.GetNumericValue(clean[i]) * (i % 2 == 0 ? 1 : 3);
        return (10 - (sum % 10)) % 10;
    }

    /// <summary>
    /// Format ISBN-13 as 978-X-XXX-XXXXX-X for display.
    /// Uses a simple 3-1-3-5-1 split (standard Bookland/EAN prefix groups).
    /// </summary>
    public static string Format(string isbn)
    {
        string clean = Normalise(isbn);
        if (clean.Length != 13) return isbn;
        // 978-[1]-[3]-[5]-[1]
        return clean.Substring(0,3) + "-" + clean[3] + "-" + clean.Substring(4,3) + "-" + clean.Substring(7,5) + "-" + clean[12];
    }

    /// <summary>Convert legacy ISBN-10 to ISBN-13.</summary>
    public static string FromISBN10(string isbn10)
    {
        string clean = Normalise(isbn10);
        if (clean.Length != 10 || !Regex.IsMatch(clean.Substring(0,9), @"^\d{9}$"))
            throw new ArgumentException("Invalid ISBN-10.");
        string prefix12 = "978" + clean.Substring(0, 9);
        int check = CalculateCheckDigit(prefix12);
        return prefix12 + check;
    }

    /// <summary>Returns just the clean 13-digit string or throws if invalid.</summary>
    public static string Parse(string input)
    {
        string clean = Normalise(input);
        if (!IsValid(clean))
            throw new FormatException("'" + input + "' is not a valid ISBN-13.");
        return clean;
    }

    /// <summary>Generate a barcode string for a physical copy: ISBN13-001, ISBN13-002…</summary>
    public static string GenerateCopyBarcode(string isbn13, int copyNumber)
    {
        return Normalise(isbn13) + "-" + copyNumber.ToString("000");
    }
}
