// fxHexLuminance.pq — Power Query custom function
// Returns WCAG relative luminance (0..1) for a HEX color string like "#RRGGBB", "RRGGBB", or short "#RGB".
// Uses sRGB piecewise gamma with current threshold 0.04045 (set LegacyThreshold to true to use 0.03928).
(let hex as nullable text, optional LegacyThreshold as nullable logical) as nullable number =>
let
    Input = if hex = null then "" else Text.Upper(Text.Trim(hex)),
    Clean1 = Text.Replace(Input, "#", ""),
    CleanHex =
        if Text.Length(Clean1) = 3 then
            Text.Middle(Clean1,0,1) & Text.Middle(Clean1,0,1) &
            Text.Middle(Clean1,1,1) & Text.Middle(Clean1,1,1) &
            Text.Middle(Clean1,2,1) & Text.Middle(Clean1,2,1)
        else
            Clean1,
    IsValid =
        Text.Length(CleanHex) = 6 and
        List.MatchesAny(Text.ToList(CleanHex), (c)=> not Text.Contains("0123456789ABCDEF", c)) = false,
    SafeHex = if IsValid then CleanHex else null,

    HexToDec = (h as text) as number =>
        let D = "0123456789ABCDEF",
            A = Text.PositionOf(D, Text.Start(h,1)),
            B = Text.PositionOf(D, Text.End(h,1))
        in A*16 + B,

    Rhex = if SafeHex = null then null else Text.Start(SafeHex, 2),
    Ghex = if SafeHex = null then null else Text.Range(SafeHex, 2, 2),
    Bhex = if SafeHex = null then null else Text.Range(SafeHex, 4, 2),

    Rdec = if Rhex = null then null else HexToDec(Rhex),
    Gdec = if Ghex = null then null else HexToDec(Ghex),
    Bdec = if Bhex = null then null else HexToDec(Bhex),

    Threshold = if LegacyThreshold = true then 0.03928 else 0.04045,

    Luminance =
        if Rdec = null or Gdec = null or Bdec = null then null else
        let
            R = Number.From(Rdec) / 255.0,
            G = Number.From(Gdec) / 255.0,
            B = Number.From(Bdec) / 255.0,
            Gamma = (c as number) as number =>
                if c <= Threshold then c / 12.92 else Number.Power((c + 0.055)/1.055, 2.4),
            Rlin = Gamma(R),
            Glin = Gamma(G),
            Blin = Gamma(B)
        in
            0.2126*Rlin + 0.7152*Glin + 0.0722*Blin
in
    Luminance
