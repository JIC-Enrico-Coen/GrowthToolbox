function s = update1StreamlineGeometry( m, s )
%m = updateStreamlineGeometry( m )
%   For every streamline, recalculate the global coordinates of every node
%   and the lengths of the segments.

    s.globalcoords = zeros( size(s.barycoords) );
    for i = 1:length(s.vxcellindex)
        s.globalcoords(i,:) = s.barycoords(i,:) * m.nodes( m.tricellvxs( s.vxcellindex(i), : ), :);
    end
    s.segmentlengths = sqrt( sum( (s.globalcoords( 1:(end-1), : ) - s.globalcoords( 2:end, : )).^2, 2 ) );
    s.directionglobal = streamlineGlobalDirection( m, s );
end
