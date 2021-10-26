function textToSliderCallback( hObject, eventdata )
%textToSliderCallback( hObject, eventdata )
    userData = get( hObject, 'UserData' );
    x = handleTextToSlider( hObject, userData.hSlider, userData );
    if isfield( userData, 'Callback' )
        cb = userData.Callback;
        cb( userData.hSlider, userData.name, x );
    end
end
