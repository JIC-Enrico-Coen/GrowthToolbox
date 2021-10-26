function m = updateStreamlineGeometry( m )
%m = updateStreamlineGeometry( m )
%   For every streamline, recalculate the global coordinates of every node
%   and the lengths of the segments.

    for si = 1:length(m.tubules.tracks)
        m.tubules.tracks(si) = update1StreamlineGeometry( m, m.tubules.tracks(si) );
    end
end
