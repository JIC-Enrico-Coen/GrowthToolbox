function c = bgColorPick( hObject, title )
    currentColor = get( hObject, 'BackgroundColor' );
    if nargin < 2
        c = uisetcolor( currentColor );
    else
        c = uisetcolor( currentColor, title );
    end
    if (length(c)==3) && any( c ~= currentColor )
        set( hObject, 'BackgroundColor', c );
    else
        c = 0;
    end
end
