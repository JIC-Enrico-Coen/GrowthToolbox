function defaultButtonDownFcn( hObject, eventData )
%defaultButtonDownFcn( hObject, eventData )
%   Install this into any graphics object that should pass button down
%   events to its parent.  IMHO, this ought to be the default behaviour,
%   but the default behaviour is to ignore the event.
%
%   For objects that process some mouse-down events but not others, call
%   this function from that object's ButtonDownFcn when it decides it does
%   not want to handle the event itself.

    h = get( hObject, 'Parent' );
    while ishandle(h)
        f = tryget( h, 'ButtonDownFcn' );
        if ~isempty(f)
            f( hObject, eventData );
            return;
        end
        h = get(h, 'Parent');
    end
end
