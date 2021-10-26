function announceSimStatus( handles, m )
%announceSimStatus( handles, m )
%announceSimStatus( handles )
%announceSimStatus( m )
%   Update the report of leaf size, number of iterations, etc. in the GUI
%   display.

    if isGFtboxMesh( handles )
        m = handles;
        setMyLegend( m );
        return;
    end

    if (nargin < 2) || isempty( m )
        m = handles.mesh;
    end
    if isempty( m )
        s = '';
    else
        s = simStatusString( m );
    end
    set( handles.report, 'String', s );
    
    % Why are we also updating the legend?
    if isempty(s)
        set( handles.legend, 'String', '', 'Visible', 'off' );
    else
        setMyLegend( m );
    end
end
