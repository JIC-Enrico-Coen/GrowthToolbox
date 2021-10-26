function [az,el,roll] = currentView( m )
    if isempty( m.pictures )
        az = [];
        el = [];
        roll = [];
    else
        h = guidata( m.pictures(1) );
        [az,el,roll] = getview( h.picture );
        if isfield( h, 'stereooffset' )
            az = az - h.stereooffset;
        end
        % Correct for vergence?  h.stereooffset.
    end
end
