function installDefaultButtonDownFcn( h )
%installDefaultButtonDownFcn( h )
%   Install a default ButtonDownFcn into h and all of the children of h,
%   recursively.  defaultButtonDownFcn transmits mouse-down events to the
%   first ancestor that has a nonempty ButtonDownFcn property.

    fprintf( 1, '%s\n', mfilename() );
    
    tryset( h, 'ButtonDownFcn', @defaultButtonDownFcn );
    hc = get( h, 'Children' );
    for i=1:length(hc)
        installDefaultButtonDownFcn( hc(i) );
    end
end
