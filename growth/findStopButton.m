function b = findStopButton( m )
%b = findStopButton( m )
%   Find the stop button in the GUI, if present.

    b = [];
    if isfield( m, 'stopButton' ) && ~isempty( m.stopButton ) && ishghandle( m.stopButton )
        b = m.stopButton;
    elseif hasPicture(m)
        f = m.pictures(1);
        h = guidata(f);
        if isfield( h, 'stopButton' )
            b = h.stopButton;
        end
    end
end

