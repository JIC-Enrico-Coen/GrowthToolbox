function setTextAndSlider( h, x )
%setTextAndSlider( h, x )
%   H is either a text object or a slider, of a pair which are linked to
%   each other.  x is a double.  The slider is given the value of x, and
%   the text object is given the value as a string.

    style = get( h, 'Style' );
    ud = get(h, 'UserData' );
    if strcmp( style, 'slider' )
        hSlider = h;
        hText = ud.hText;
    else
        hSlider = ud.hSlider;
        hText = h;
    end
    set( hText, 'String', num2str( x ) );
    handleTextToSlider( hText, hSlider, ud );
end

