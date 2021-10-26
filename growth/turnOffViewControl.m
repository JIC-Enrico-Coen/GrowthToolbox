function turnOffViewControl( handles )
    set( handles.zoomToggle, 'Value', 0 );
    set( handles.rotateToggle, 'Value', 0 );
    set( handles.rotuprightToggle, 'Value', 0 );
    set( handles.panToggle, 'Value', 0 );
    setUserdataFields( handles.picture, 'dragmode', 'off' );
end
