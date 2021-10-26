function bcs = randInTriangleGradient( vxWts, n )
%bcs = randInTriangleGradient( vertexWeights, n )
%   Select n points in a triangle, distributed according to a probability
%   density specified by its values at the vertexes, and linearly
%   interpolated over the triangle. The result is a set of n points in
%   barycentric coordinates. We do not need to know the actual location of
%   the triangle's vertexes.

    maxWt = max( vxWts );
    remaining = n;
    numfound = 0;
    bcs = zeros( n, 3 );
    numiters = 0;
    prismvolume = max(vxWts);
    shapeVolume = mean(vxWts);
    oversampling = prismvolume/shapeVolume;
    while remaining > 0
        numsamples = round( remaining * oversampling );
        bc = randBaryCoords( numsamples, 2 );
        ok = maxWt*rand(numsamples,1) < bc*vxWts';
        newpts = bc(ok,:);
        numnewpts = size(newpts,1);
        if numnewpts > remaining
            newpts((remaining+1):end,:) = [];
            numnewpts = remaining;
        end
        bcs((numfound+1):(numfound+numnewpts),:) = newpts;
        remaining = remaining - numnewpts;
        numfound = numfound + numnewpts;
        numiters = numiters+1;
%         fprintf( 1, 'Iteration %d, remaining %d.\n', numiters, remaining );
    end
    
%     plotpts( bcs, '.' );
%     axis equal;
%     xlabel('x')
%     ylabel('y')
end
