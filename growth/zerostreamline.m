function s = zerostreamline( s )
% Delete all vertexes from the streamline, but preserve all other data.

    s.vxcellindex = zeros( 1, 0, 'int32' );
    s.segcellindex = zeros( 1, 0, 'int32' );
    s.barycoords = zeros( 0, 3, 'double' );
    s.globalcoords = zeros( 0, 3, 'double' );
    s.segmentlengths = zeros( 1, 0, 'double' );
    s.directionbc = [0 0 0];
    s.directionglobal = [0 0 0];
end
