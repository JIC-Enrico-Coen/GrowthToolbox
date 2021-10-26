function value = handleTextToSlider( texthandle, sliderhandle, params )
    [ value, ok1 ] = getDoubleFromDialog( texthandle );
    if ok1
        maxval = get( sliderhandle, 'Max' );
        minval = get( sliderhandle, 'Min' );
        maxtextpriority = isfield( params, 'textpriority' ) && params.textpriority && isfield( params, 'max' );
        mintextpriority = isfield( params, 'textpriority' ) && params.textpriority && isfield( params, 'min' );
        if maxtextpriority
            if value > params.max
                set( sliderhandle, 'Max', value );
            elseif maxval ~= params.max
                set( sliderhandle, 'Max', params.max );
            end
        else
            if value > maxval
                value = maxval;
                set( texthandle, 'String', num2str( value ) );
            end
        end
        if mintextpriority
            if value < params.min
                set( sliderhandle, 'Min', value );
            elseif minval ~= params.min
                set( sliderhandle, 'Min', params.min );
            end
        else
            if value < minval
                value = minval;
                set( texthandle, 'String', num2str( value ) );
            end
        end
        set( sliderhandle, 'Value', value );
    end
end
