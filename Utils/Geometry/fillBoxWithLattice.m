function latticepts = fillBoxWithLattice( bbox, initpoint, latticevectors )

% BBOX is 2*3: BBOX(1,:) is the lower bounds and BBOX(2,:) the upper
% bounds.

    bboxvecs = diag( bbox(2,:)-bbox(1,:) );
    bboxvxs = [ bbox(1,:); ...
                bbox(1,:) + bboxvecs; ...
                bbox(2,:) - bboxvecs; ...
                bbox(2,:) ];

%     invlatticevecs = inv( latticevectors );
    invinitpoint = initpoint / latticevectors;
    invbbox = bbox / latticevectors;
    invbboxvecs = bboxvecs / latticevectors;
    
    % Calculate all the vertexes of the inverse bounding box.
    invbboxvxs = [ invbbox(1,:); ...
                   invbbox(1,:) + invbboxvecs; ...
                   invbbox(2,:) - invbboxvecs; ...
                   invbbox(2,:) ];
                   
    % Enclose the inverse bbox by an axis-aligned bbox.
    aainvbbox = [ min( invbboxvxs, [], 1 ); ...
                  max( invbboxvxs, [], 1 ) ];
    
    % Place the inverse init point at the origin.
    aainvbbox = aainvbbox - invinitpoint;
    
    % Make a grid of cell centres.
    mincentres = ceil( aainvbbox(1,:) );
    maxcentres = floor( aainvbbox(2,:) );
    
    xvals = (mincentres(1):maxcentres(1)) + invinitpoint(1);
    yvals = (mincentres(2):maxcentres(2)) + invinitpoint(2);
    zvals = (mincentres(3):maxcentres(3)) + invinitpoint(3);
    nx = length(xvals);
    ny = length(yvals);
    nz = length(zvals);
    
    invlatticepts = [ repmat( xvals', ny*nz, 1 ), ...
                      reshape( repmat( yvals, nx, nz ), [], 1 ), ...
                      reshape( repmat( zvals, nx*ny, 1 ), [], 1 ) ];
    alllatticepts = invlatticepts * latticevectors;
    inside = ptsInAabbox( bbox, alllatticepts );
    latticepts = alllatticepts( inside, : );

    [fig1,ax1] = getFigure();
    plotpts( ax1, alllatticepts(~inside,:), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'r' );
    hold on
    plotpts( ax1, latticepts, 'LineStyle', 'none', 'Marker', 'o', 'Color', 'b' );
%     plotbox( ax1, 
    hold off
    ax1.XLabel.String = 'X';
    ax1.YLabel.String = 'Y';
    ax1.ZLabel.String = 'Z';
    axis equal;
end

function inside = ptsInAabbox( bbox, pts )
    inside = true(size(pts,1),1);
    for i=1:size(pts,2)
        inside = inside & (pts(:,i) >= bbox(1,i)) & (pts(:,i) <= bbox(2,i));
    end
end
