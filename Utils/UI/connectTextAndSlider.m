function connectTextAndSlider( hText, hSlider, name, callback, textpriority )
%connectTextAndSlider( hText, hSlider, name, callback, textpriority )
%   Connect the text item and the slider, so that changes to either will
%   show up in the other and invoke the callback.
%   The callback should expect to be called thus:
%       callback( hObject, name, x )
%   where hObject is the handle to the slider and x is the value, of type
%   double.
%   NAME and CALLBACK can be omitted.

    userData = get( hText, 'UserData' );
    userData.hSlider = hSlider;
    userData.hText = hText;
    userData.min = get( hSlider, 'Min' );
    userData.max = get( hSlider, 'Max' );
    userData.textpriority = textpriority;
    if ~isempty(name)
        userData.name = name;
    end
    if ~isempty(callback)
        userData.Callback = callback;
    end
    set( hText, 'UserData', userData );

    userData = get( hSlider, 'UserData' );
    userData.hText = hText;
    if nargin > 3, userData.Callback = callback; end
    if nargin > 2, userData.name = name; end
    set( hSlider, 'UserData', userData );

    set( hText, 'Callback', @textToSliderCallback );
    set( hSlider, 'Callback', @sliderToTextCallback );
    textToSliderCallback( hText );
end
