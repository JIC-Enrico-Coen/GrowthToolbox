function setSliderAndText( hSlider, value )
%setSliderAndText( hSlider, value )
%   hSlider is the handle to a slider control.  Its UserData field is
%   assumed to be a structu whose hText field is a handle to an editable
%   text item which is intended to display the current value of the
%   slider.  This procedure sets both controls to display that value.

    set( hSlider, 'Value', value );
    ud = get( hSlider, 'UserData' );
    setDoubleInTextItem( ud.hText, value );
end
