function value = handleSliderToText( texthandle, sliderhandle )
    value = get( sliderhandle, 'Value' );
    set( texthandle, 'String', num2str( value ) );
end
