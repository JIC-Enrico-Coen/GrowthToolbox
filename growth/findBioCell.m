function cells = findBioCell( m, pts )
%cells = findBioCell( m, pts )
%   pts is an N*3 array of N points.  This function returns an N*1 array
%   specifying for each point, which biological cell it lies within.  If it
%   does not lie within any bio cell, the corresponding value will be zero.

    numpts = size(pts,1);
    cells = zeros( numpts, 1 );
    if ~isfield( m.secondlayer, 'cells' )
        % No bio layer.
        return;
    end
    numcells = length( m.secondlayer.cells );
    if numcells==0
        % No cells.
        return;
    end
    for i=1:numpts
        for j=1:numcells
            cv = m.secondlayer.cell3dcoords( m.secondlayer.cells(j).vxs, [1 2] );
            if all(pts(i,1) < cv(:,1)) ...
               || all(pts(i,1) > cv(:,1)) ...
               || all(pts(i,2) < cv(:,2)) ...
               || all(pts(i,2) > cv(:,2))
                continue;
            end
            if pointInPoly( pts(i,:), cv );
                cells(i) = j;
                break;
            end
        end
    end
end
