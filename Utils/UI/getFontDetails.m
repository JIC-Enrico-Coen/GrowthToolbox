function fd = getFontDetails( h )
%fd = getFontDetails( h )
%   Find the font properties of the graphics handle h.  The result is a
%   structure with the fields FontName, FontUnits, FontSize, FontWeight,
%   and FontAngle.  All values are strings.  Missing fields are returned as
%   empty strings.

    fd.FontName = tryget( h, 'FontName' );
    fd.FontUnits = tryget( h, 'FontUnits' );
    fd.FontSize = tryget( h, 'FontSize' );
    fd.FontWeight = tryget( h, 'FontWeight' );
    fd.FontAngle = tryget( h, 'FontAngle' );
end
