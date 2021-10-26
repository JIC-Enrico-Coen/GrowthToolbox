function rollzero_ButtonDownFcn( hObject, varargin )
    h = guidata( hObject );
    set( h.roll, 'Value', 0 );
    viewScroll_Callback( h.roll, [] );
end
