function v = polyhedronVolume( vxs, faces )
    numdims = size(vxs,2);
    allvxindexes = unique( cell2mat( faces ) );
    centre = mean( vxs(allvxindexes,:), 1 );
    numtetras = 0;
    for i=1:length(faces)
        numtetras = numtetras + length(faces{i}) - 2;
    end
    v = zeros( numtetras, 1 );
    vi = 0;
    for i=1:length(faces)
        fvxs = faces{i};
        ftris = [ fvxs(1)+zeros(length(fvxs)-2,1,'uint32'), fvxs(2:(end-1)), fvxs(3:end) ];
        for j=1:size(ftris,1)
            vi = vi+1;
            v(vi) = absTetraVolume6( [ vxs(ftris(j,:), : ); centre ] );
        end
    end
    if vi ~= numtetras
        error( 'Wrong number of tetras, expected %d, found %d.', numtetras, vi );
    end
    v = sum(v)/6;
end

function v = absTetraVolume6( vxs )
% Returns 6 times the volume of the tetrahedron given by the four vertexes.
% vxs must be a 4*3 array. The result is always non-negative, regardless of
% the sense of the tetrahedron.

    v = abs( det( vxs(2:4,:) - vxs(1,:) ) );
end