function sliderToTextCallback( hObject, eventdata )
%sliderToTextCallback( hObject, eventdata )
    userData = get( hObject, 'UserData' );
    x = handleSliderToText( userData.hText, hObject );
    if isfield( userData, 'Callback' ) && ~isempty(userData.Callback)
        cb = userData.Callback;
        cb( hObject, userData.name, x );
    end
end
