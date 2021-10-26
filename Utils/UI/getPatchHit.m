function n = getPatchHit( patchHandle, hitPoint )
%n = getPatchHit( patchHandle, hitPoint )
%   Given the hitPoint as returned by get( theaxes, 'CurrentPoint' ) and a
%  patch handle, determine which polygon was hit.  Matlab must know this,
%  in order to have detected a hit on the patch, but I can't find any way
%  of getting this information.
%
%  The test is performed by determining which of the polygons enclose the
%  line, and then taking the one whose centroid is closest to the near end
%  of the line.

    x = get( patchHandle, 'XData' );
    y = get( patchHandle, 'YData' );
    z = get( patchHandle, 'ZData' );

    numpoly = size(x,2);
    encloseMap = false( 1, numpoly );
% %{
    polysize = ones( 1, numpoly ) * size(x,1);
    for i=1:numpoly
        firstbad = find( isnan(x), 1 );
        if ~isempty(firstbad)
            polysize(i) = firstbad - 1;
        end
        pts = [ x(1:polysize(i),i), y(1:polysize(i),i), z(1:polysize(i),i) ];
        encloseMap(i) = enclosesLine( pts, hitPoint );
    end
% %}
    encloseIndexes = find(encloseMap);
    if isempty(encloseIndexes)
        n = 0;
    elseif length(encloseIndexes)==1
        n = encloseIndexes;
    else
        vsq = zeros( 1, length(encloseIndexes) );
        for i=1:length(encloseIndexes)
            ei = encloseIndexes(i);
          % centroid = sum( [ x(1:polysize(i),ei), ...
          %                   y(1:polysize(i),ei), ...
          %                   z(1:polysize(i),ei) ], 1 )/polysize(i);
            centroid = sum( [ x(:,ei), ...
                              y(:,ei), ...
                              z(:,ei) ], 1 )/polysize(i);
            v = centroid - hitPoint(1,:);
            vsq(i) = sum(v.*v);
        end
        [m,vi] = min( vsq );
        n = encloseIndexes(vi);
    end
end
