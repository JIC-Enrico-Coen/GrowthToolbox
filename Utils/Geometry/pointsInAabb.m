function [allcontainments,quality] = pointsInAabb( pts, aabb )
    dims = size(pts,2);
    allcontainments = zeros( size(pts,1)*4, 2 );
    quality = zeros( size(pts,1), 1 );
    numcontainments = 0;
    for i=1:size(pts,1)
        dist = -inf(size(aabb,1),1);
        for j=1:dims
            dist = max( dist, aabb(:,j) - pts(i,j) );
        end
        for j=1:dims
            dist = max( dist, pts(i,j) - aabb(:,j+dims) );
        end
        in = dist<0;
        whichnonempty = find(in);
        if isempty(whichnonempty)
            [q,whichnonempty] = min(dist);
        else
            q = -ones(length(whichnonempty),1);
        end
        numnewintersections = length(whichnonempty);
        allcontainments( (numcontainments+1):(numcontainments+numnewintersections), : ) = ...
            [ i+zeros(numnewintersections,1), whichnonempty ];
        quality( (numcontainments+1):(numcontainments+numnewintersections), : ) = q;
        numcontainments = numcontainments+numnewintersections;
    end
    allcontainments( (numcontainments+1):end,:) = [];
end
