function GFtboxUpdateFonts(FontDetails,handle,OldFontDetails)
    if ~isstruct( FontDetails )
        return;
    end
    if isprop(handle,'FontName') && nonEmptyField(FontDetails,'FontName')
        handle.FontName = FontDetails.FontName;
    end
    if isprop(handle,'FontSize') && nonEmptyField(FontDetails,'FontSize')
        if isempty(OldFontDetails.FontSize)
            handle.FontSize = FontDetails.FontSize;
        else
            oldFontSize = get(handle,'FontSize');
            handle.FontSize = FontDetails.FontSize + oldFontSize - OldFontDetails.FontSize;
        end
    end
    children=get(handle,'children');
    for i=1:length(children)
        child=children(i);
        GFtboxUpdateFonts(FontDetails,child,OldFontDetails);
    end
end

function has = nonEmptyField( s, f )
    has = isfield(s,f) && ~isempty(s.(f));
end
