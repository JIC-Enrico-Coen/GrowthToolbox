function [sl,ok] = makeCellGrid( type, bbox, ndivs, nsubdivs, plane, hemisphere, range, numcells )
%[sl,ok] = makeCellGrid( type, bbox, ndivs, nsubdivs, plane, hemisphere, range, numcells )
%   Construct grids of cells of various sorts.
%   If m is given and returned, install this as a cellular layer into m.
%
%   TYPE is one of:
%   radial: Make a circular grid with radial and circumferential edges.
%       ndivs(1) is the number of cells around and ndivs(2) the number of
%       rings of cells.
%   grid: Make a rectangular grid with ndivs(1) and ndivs(2) cells each
%       way.
%   circlegrid: Make a rectangular grid as for type 'grid', but trim it to
%       a circular region.
%   latlong: Make a spherical grid of latitude and longitude lines.
%       ndivs(1) is the number of cells around the equator and ndivs(2) the
%       number from pole to pole.
%   box: Make a box of which each side is divided into a grid.  ndivs has
%       three elements, the number of cells along each of the three axes.
%   spherebox: As box, but project the resulting cells onto the surface of
%       a sphere.
%   hemisphere: 
%
%   BBOX is the bounding box within which to construct the cells. It may be
%       given in 2 or 3 dimensions.
%
%   NDIVS is the number of divisions as specified above.
%
%   NSUBDIVS has the same number of elements as ndivs, and specifies the
%       number of sub-edges each cell edge is divided into in the
%       corresponding direction.  The default values are 1 (i.e. no
%       subdivision).
%
%   PLANE: One of the strings 'XY', 'YX', 'XZ', 'ZX', 'YZ', or 'ZY' (case is
%       ignored). This specifies the plane in which a flat mesh lies (or is
%       parallel to), the equatorial plane of a latlong mesh, or the first
%       two axes of a box or spherebox mesh.  The default is 'XZ'.
%
%   If ADD is true, the cells are added to any existing cellular layer. If
%   false, any existing cells are deleted.

    if (nargin < 5) || isempty(nsubdivs)
        nsubdivs = ones(size(ndivs));
    end        
    if (nargin < 6) || isempty(plane)
        plane = 'XZ';
    end
    if nargin < 7
        add = false;
    end
    if nargin < 8
        range = [];
    end
    if nargin < 9
        m = [];
    end
    
    ok = true;
    
    subdivhandled = isempty( nsubdivs ) || all(nsubdivs <= 1);
    
    scalingneeded = true;
    
    switch type
        case 'SolidHemisphere3D'
            % Make a mesh covering the whole surface of a solid hemisphere.
            numcellsPlane = ceil( numcells/3 );
            numcellsHemisphere = numcells - numcellsPlane;
            totalCells = numcellsPlane + numcellsHemisphere;
            fprintf( 1, 'About to make "%s" voronoi layer of %d cells.\n', type, totalCells );
            [cellsPlane,vxsPlane,~] = makeVoronoiEllipse( numcellsPlane, 8, [-1 1 -1 1], true );
%             [cellsPlane,vxsPlane,~] = makeVoronoiEllipse( numcellsPlane, 8, [meshbbox(1,2) meshbbox(2,2) meshbbox(1,3) meshbbox(2,3)], true );
            vxsPlane = [vxsPlane zeros(size(vxsPlane,1),1)];
            sl1 = struct( 'pts', vxsPlane, 'cellvxs', cellToRaggedArray( cellsPlane, NaN, true ) );
            [cellsHemisphere,vxsHemisphere,~] = makeVoronoiEllipse( numcellsHemisphere, 8, [-1 1 -1 1], true );
            vxsHemisphere(:,2) = -vxsHemisphere(:,2);
            vxsHemisphere = mapCircleToHemisphere( vxsHemisphere, 1.618 );
            sl2 = struct( 'pts', vxsHemisphere, 'cellvxs', cellToRaggedArray( cellsHemisphere, NaN, true ) );
            sl = joinCellLayers( sl1, sl2 );
            
            centre = (bbox(1,:) + bbox(2,:))/2;
            scaling = bbox(2,:) - centre;
            sl.pts = centre + sl.pts .* scaling;
            scalingneeded = false;
        case 'EquatorialYZVoronoi'
            % Make a circular mesh on the equator of the object.
            fprintf( 1, 'About to make "%s" voronoi layer of %d cells.\n', type, numcells );
            [cells,vxs,~] = makeVoronoiEllipse( numcells, 8, [bbox(1,2) bbox(2,2) bbox(1,3) bbox(2,3)], true );
            vxs = [-0.015*ones(size(vxs,1),1) vxs];
            sl = safemakestruct( mfilename(), { 'pts', vxs, 'cellvxs', cellToRaggedArray( cells, NaN ) } );
            scalingneeded = false;
        case 'Block3DVoronoi'
            % Make five rectangular Voronoi meshes, for the top and four sides (excluding the bottom) of a block.
            xyzlo = bbox(1,:); % min(m.FEnodes,[],1);
            xyzhi = bbox(2,:); % max(m.FEnodes,[],1);
            xyzrange = xyzhi - xyzlo;
            
            area1 = xyzrange(1)*xyzrange(3);
            area2 = xyzrange(2)*xyzrange(3)/2;
            area3 = xyzrange(1)*xyzrange(2)/2;
            area4 = area1;
            area5 = area2;
            areas = [area1 area2 area3 area4 area5];
            relareas = areas/sum(areas);
            cellsperface = max( 1, round( relareas*numcells ) );
            
            xyzmid = (xyzlo+xyzhi)/2;
            
            totalCells = sum(cellsperface)*2;
            fprintf( 1, 'About to make "%s" voronoi layer of %d cells.\n', type, totalCells );
            
            % Front. The XZ plane through the centre of the block.
            [cells1,vxs1,~] = makeVoronoiRectangle( cellsperface(1), 20, [xyzlo(1) xyzhi(1) xyzlo(3) xyzhi(3)], true );
            vxs1 = [ vxs1(:,1), xyzmid(2) + zeros(size(vxs1,1),1), vxs1(:,2) ];
            sl1 = safemakestruct( mfilename(), { 'pts', vxs1, 'cellvxs', cellToRaggedArray( cells1, NaN ) } );
            
            % +X side. This is in the YZ plane, from Y=0 to Y=maximum, and
            % X everywhere = maximum.
            [cells2,vxs2,~] = makeVoronoiRectangle( cellsperface(2), 20, [xyzmid(2) xyzhi(2) xyzlo(3) xyzhi(3)], true );
            vxs2 = [ xyzhi(1) + zeros(size(vxs2,1),1), vxs2 ];
            sl2 = safemakestruct( mfilename(), { 'pts', vxs2, 'cellvxs', cellToRaggedArray( cells2, NaN ) } );
            
            % Top.
            [cells3,vxs3,~] = makeVoronoiRectangle( cellsperface(3), 20, [xyzlo(1) xyzhi(1), xyzmid(2) xyzhi(2)], true );
            vxs3 = [ vxs3, xyzhi(3) + zeros(size(vxs3,1),1) ];
            sl3 = safemakestruct( mfilename(), { 'pts', vxs3, 'cellvxs', cellToRaggedArray( cells3, NaN ) } );
            
            % Back. The XZ plane on the back of the block. This is a
            % duplicate of the front, mirrored on the X axis (to give the
            % polygons the correct sense).
            cells4 = cells1;
            vxs4 = [ xyzlo(1) + xyzhi(1) - vxs1(:,1), xyzhi(2) + zeros(size(vxs1,1),1), vxs1(:,3) ];
            sl4 = safemakestruct( mfilename(), { 'pts', vxs4, 'cellvxs', cellToRaggedArray( cells4, NaN ) } );
            
            % -X side. This is a duplicate of the +X side, with X =
            % minimum, mirrored on the Y axis (to give the polygons the
            % correct sense).
            cells5 = cells2;
            vxs5 = [ xyzlo(1) + zeros(size(vxs2,1),1), xyzmid(2) + xyzhi(2) - vxs2(:,2), vxs2(:,3) ];
            sl5 = safemakestruct( mfilename(), { 'pts', vxs5, 'cellvxs', cellToRaggedArray( cells5, NaN ) } );
            
            sl = combineGrids( [ sl1, sl2, sl3, sl4, sl5 ] );
%             m = leaf_refinebioedges( m, 'refinement', s.subdivisions );
            scalingneeded = false;
            xxxx = 1;
        case 'MakePrim3DVoronoi'
            % Make four Voronoi meshes, three rectangular and one circular.
            % Position them 
%             [sl,m,ok] = makeCellGrid( s.mode, s.magnitude, s.centre, s.divisions, s.subdivisions, s.plane, s.add, s.hemisphere, s.range, m );
            xyzlo = bbox(1,:); % min(m.FEnodes,[],1);
            xyzhi = bbox(2,:); % max(m.FEnodes,[],1);
            
            area1 = (xyzhi(1)-xyzlo(1))*(xyzhi(3)-xyzlo(3));
            area2 = area1*pi/2;
            area3 = (xyzhi(1)-xyzlo(1))*(xyzhi(2)-xyzlo(2))*(pi/8);
            area = area1+area2+area3;
            
            f1 = area1/area;
            f2 = area2/area;
%             f3 = area3/area;
            n1 = round(numcells*f1);
            n2 = round(numcells*f2);
            n3 = numcells - n1 - n2;
            
            totalCells = n1+n2+n3;
            fprintf( 1, 'About to make "%s" voronoi layer of %d cells.\n', type, totalCells );
            
            [cells1,vxs1,~] = makeVoronoiRectangle( n1, 8, [xyzlo(1) xyzhi(1) xyzlo(3) xyzhi(3)], true );
            vxs1 = [ vxs1(:,1), zeros(size(vxs1,1),1), vxs1(:,2) ];
            sl1 = safemakestruct( mfilename(), { 'pts', vxs1, 'cellvxs', cellToRaggedArray( cells1, NaN ) } );
            radius = (xyzhi(1) - xyzlo(1))/2;
            [cells2,vxs2,~] = makeVoronoiRectangle( n2, 8, [0 pi*radius xyzlo(3) xyzhi(3)], true );
            vxs2 = wrapRectangleToCylinder( vxs2, [0 pi*radius xyzlo(3) xyzhi(3)], [0 pi xyzlo(3) xyzhi(3)], radius );
            sl2 = safemakestruct( mfilename(), { 'pts', vxs2, 'cellvxs', cellToRaggedArray( cells2, 0 ) } );
            [cells3,vxs3,~] = makeVoronoiSemiEllipse( n3, 8, [-radius radius 0 radius], true );
            vxs3(:,3) = xyzhi(3);
%             vxs3 = vxs3(:,[2 1 3]);
            sl3 = safemakestruct( mfilename(), { 'pts', vxs3, 'cellvxs', cellToRaggedArray( cells3, 0 ) } );
            
            sl = combineGrids( [ sl1, sl2, sl3 ] );
            scalingneeded = false;
            xxxx = 1;
        case 'MakePrim3DGrid'
            divsaround = ndivs(1);
            divsradial = ndivs(2);
            divsup = ndivs(3);
            % Make a grid in the XZ plane.
            sl1 = make2DGrid( [divsup, divsradial*2], nsubdivs([3 2]), [] );
            sl1 = setplane( sl1, 'ZX' );
            
            totalCells = divsaround*divsup + divsaround*divsradial;
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, totalCells );
            
            % Make a grid around the cylindrical face, on the +Y side.
            sl2 = makeCylinderGrid( [divsaround,divsup], nsubdivs([1 3]), [[divsaround/2;divsaround],[0;divsup]] );
%             sl2 = setplane( sl2, 'ZX' );
            % Make a radial/circumferential grid on the top.
            sl3 = makeCircularRadialGrid( [divsaround,divsradial], nsubdivs([1 2]), [[divsaround/2;divsaround],[0;divsradial]] );
%             sl3 = setplane( sl3, 'XY' );
            sl3.pts(:,3) = 1;
            % Stitch these together.
            sl = combineGrids( [ sl1, sl2, sl3 ], 1e-6 );
            subdivhandled = true;
            scalingneeded = true;
        case 'test'
            
            totalCells = 2*prod(ndivs([1 2]));
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, totalCells );
            
            sl1 = makeCircularRadialGrid( ndivs, nsubdivs, [] );
            sl1 = setplane( sl1, 'XZ' );
            sl2 = makeSphericalLatLongGrid( ndivs, nsubdivs, round([ ndivs(1)/2 0; ndivs(1) ndivs(2) ]) );
            % Reverse the cells in sl2 in order to match the sense of sl1,
            % to avoid problems when stitching them together.
            sl2.cellvxs = reverseRaggedArray( sl2.cellvxs );
            sl = combineGrids( [ sl1, sl2 ], 1e-6 );
            subdivhandled = true;
            scalingneeded = true;
            xxxx = 1;
        case 'testXY'
            
            totalCells = 2*prod(ndivs([1 2]));
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, totalCells );
            
            sl1 = makeCircularRadialGrid( ndivs, nsubdivs, [] );
            sl1 = setplane( sl1, 'XY' );
            sl2 = makeSphericalLatLongGrid( ndivs, nsubdivs, round([ 0 0; ndivs(1) ndivs(2)/2 ]) );
            % Reverse the cells in sl2 in order to match the sense of sl1,
            % to avoid problems when stitching them together.
            for i=1:size(sl2.cellvxs,1)
                z = find(sl2.cellvxs(i,:)==0,1);
                if isempty(z)
                    sl2.cellvxs(i,:) = sl2.cellvxs(i,end:-1:1);
                else
                    sl2.cellvxs(i,1:(z-1)) = sl2.cellvxs(i,(z-1):-1:1);
                end
            end
            sl = combineGrids( [ sl1, sl2 ], 1e-6 );
            subdivhandled = true;
            scalingneeded = true;
        case 'test1'
            
            totalCells = 2*prod(ndivs([1 2]));
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, totalCells );
            
            sl1 = makeCircularRadialGrid( ndivs, nsubdivs, [] );
            sl1 = setplane( sl1, 'YZ' );
            sl2 = makeSphericalLatLongGrid( ndivs, nsubdivs, round([ ndivs(1)*3/4 0; ndivs(1)*5/4 ndivs(2) ]) );
            % Reverse the cells in sl2 in order to match the sense of sl1,
            % to avoid problems when stitching them together.
            for i=1:size(sl2.cellvxs,1)
                z = find(sl2.cellvxs(i,:)==0,1);
                if isempty(z)
                    sl2.cellvxs(i,:) = sl2.cellvxs(i,end:-1:1);
                else
                    sl2.cellvxs(i,1:(z-1)) = sl2.cellvxs(i,(z-1):-1:1);
                end
            end
            sl = combineGrids( [ sl1, sl2 ], 1e-6 );
            subdivhandled = true;
            scalingneeded = true;
        case 'radial'
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, prod(ndivs([1 2])) );
            sl = makeCircularRadialGrid( ndivs, nsubdivs, range );
            subdivhandled = true;
            scalingneeded = true;
        case 'rectgrid'
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, prod(ndivs([1 2])) );
            sl = make2DGrid( ndivs, nsubdivs, range );
            subdivhandled = true;
            scalingneeded = true;
        case 'circlegrid'
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, prod(ndivs([1 2])) );
            sl = makeCircularOrthogonalGrid( ndivs, nsubdivs, range );
            subdivhandled = true;
            scalingneeded = true;
        case 'latlong'
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, prod(ndivs([1 2])) );
            sl = makeSphericalLatLongGrid( ndivs, nsubdivs, range, hemisphere );
            subdivhandled = true;
            scalingneeded = true;
        case {'box', 'spherebox'}
            totalCells = 2*sum( prod( ndivs( [1 2;2 3;3 1] ), 2 ), 1 );
            fprintf( 1, 'About to make "%s" grid layer of %d cells.\n', type, totalCells );
            sl = makeBox3DGrid( ndivs, nsubdivs, range );
            if strcmp(type,'spherebox')
                sl.pts = sl.pts ./ repmat( sqrt(sum(sl.pts.^2,2)), 1, size(sl.pts,2) );
            end
            subdivhandled = true;
    end
    
    sl = setplane( sl, plane );
    if ~isempty( bbox ) && scalingneeded
        centre = sum( bbox, 1 )/2;
        scaling = bbox(2,:)-centre;
        scaling( (end+1):size(sl.pts,2) ) = bbox(1);
        scaling( (size(sl.pts,2)+1):end ) = [];
        sl.pts = sl.pts .* repmat( scaling, size(sl.pts,1), 1 );
    end
    
%     plotsl( 1, sl );
    
%     if (~isempty(m)) && (nargout >= 2)
% %         [m1,ok] = installGrid( m, sl, add );
%         [m,ok] = installCells( m, sl.pts, sl.cellvxs, 'add', add );
%     end
end

function sl = setplane( sl, plane )
    if size(sl.pts,2)==2
        sl.pts(1,3) = 0;
    end
    plane = upper(plane);
    if length(plane)==2
        if ischar(plane)
            plane = plane - 'W';
            plane(3) = otherof3( plane(1), plane(2) );
        end
        sl.pts(:,plane) = sl.pts;
    else
        % Plane is a six-character string specifying a sequence of three
        % signed axes. This defines a rotation and reflection matrix that
        % is applied to sl.pts. For example, the string '+Z-Y-X' specifies
        % that the +X axis is to be mapped to +Z, +Y to -Y, and +Z to -X.
        % The corresponding rotation/reflection matrix is
        %     [ 0  0 -1
        %       0 -1  0
        %       1  0  0 ]
        signs = 2*(plane([1 3 5])=='+') - 1;
        axx = plane([2 4 6]) - 'W';
        mx = zeros(3,3);
        for i=1:3
            mx(i,axx(i)) = signs(i);
        end
        sl.pts = sl.pts*mx;
        if det(mx) < 0
            sl.cellvxs = reverseRaggedArray( sl.cellvxs );
        end
    end
end


function sl = makeCylinderGrid( ndivs, nsubdivs, range )
% Make a grid around the curved surface of a cylinder, or a part of it. The
% cylinder has bounds +/-1 on all three axes, and its axis is the Z axis.
% NDIVS = [AROUND, UP] specifies the number of cells around the cylinder
% and the number along its axis respectively.
% RANGE is a pair of angles [THETA1 THETA2] (defaulting to [0 2*pi])
% specifying which part of the surface is to be covered.

    if nargin < 3
        range = [0 -1; 2*pi 1];
    end
    sl = make2DGrid( ndivs, nsubdivs, range );
    sl.pts = wrapRectangleToCylinder( sl.pts(:,[1 2]), ...
        [-1 1 -1 1], ...
        [-pi pi -1 1], ...
        1 );
end



function sl = makeSphericalLatLongGrid( ndivs, nsubdivs, range, hemisphere )
    if numel(ndivs)==1
        ndivs = [ ndivs ceil(ndivs/2) ];
    end
    if numel(nsubdivs)==1
        nsubdivs = [ nsubdivs nsubdivs ];
    end
    if isempty(range)
        range = [zeros(1,length(ndivs)); ndivs];
    end
    if nargin < 4
        hemisphere = 0;
    end
    % hemisphere is either -1, 0, or 1.
    % 0 means to make the whole sphere.
    % -1 asks for the negative hemisphere only.
    % 1 asks for the positive hemisphere only.
    
    sl = make2DGrid( ndivs, nsubdivs, range );
    switch lower(hemisphere)
        case 's'
            phi = sl.pts(:,2)*(pi/4) - pi/4;
        case 'n'
            phi = sl.pts(:,2)*(pi/4) + pi/4;
        otherwise
            phi = sl.pts(:,2)*(pi/2);
    end
    theta = sl.pts(:,1)*pi;
    ctheta = cos(theta);
    stheta = sin(theta);
    cphi = cos(phi);
    sphi = sin(phi);
    sl.pts(:,1) = ctheta.*cphi;
    sl.pts(:,2) = stheta.*cphi;
    sl.pts(:,3) = sphi;
    switch lower(hemisphere)
        case 's'
            sl.pts(:,3) = sl.pts(:,3)*2 + 1;
        case 'n'
            sl.pts(:,3) = sl.pts(:,3)*2 - 1;
        otherwise
    end
    sl = combineDuplicateVerts( sl, 1e-6 );
end

function sl = makeBox3DGrid( ndivs, nsubdivs, range )
    if numel(ndivs)==1
        ndivs = [ ndivs ndivs ndivs ];
    end
    if numel(nsubdivs)==1
        nsubdivs = [ nsubdivs nsubdivs nsubdivs ];
    end
    if isempty(range)
        range = [zeros(1,length(ndivs)); ndivs];
    end
    slx = make2DGrid( ndivs([2 3]), nsubdivs([2 3]), range(:,[2 3]) );
    sly = make2DGrid( ndivs([3 1]), nsubdivs([3 1]), range(:,[3 1]) );
    slz = make2DGrid( ndivs([1 2]), nsubdivs([1 2]), range(:,[1 2]) );
    slx.pts = [ ones( size(slx.pts,1), 1 ), slx.pts ];
    sly.pts = [ sly.pts(:,2), ones( size(sly.pts,1), 1 ), sly.pts(:,1) ];
    slz.pts = [ slz.pts, ones( size(slz.pts,1), 1 ) ];
    slmx = slx;  slmx.pts = slmx.pts * [ -1 0 0; 0 -1 0; 0 0 1 ];
    slmy = sly;  slmy.pts = slmy.pts * [ 1 0 0; 0 -1 0; 0 0 -1 ];
    slmz = slz;  slmz.pts = slmz.pts * [ -1 0 0; 0 1 0; 0 0 -1 ];
    sl = combineGrids( [ slx, sly, slz, slmx, slmy, slmz ], 1e-6 );
end

function sl = make2DGrid( ndivs, nsubdivs, range )
% Make a 2D cellular grid with the given numbers of divisions and
% subdivisions.  RANGE specifies a subset to be made. The bounds of the
% grid are +/- 1 on both axes.
    if numel(ndivs)==1
        ndivs = [ ndivs ndivs ];
    end
    if numel(nsubdivs)==1
        nsubdivs = [ nsubdivs nsubdivs ];
    end
    if isempty(range)
        range = [zeros(1,length(ndivs)); ndivs];
    end
    xdivs = abs(range(2,1) - range(1,1)); % ndivs(1);
    ydivs = abs(range(2,2) - range(1,2)); % ndivs(2);
    xlo = -1 + 2*min(range(:,1))/ndivs(1);
    xhi = -1 + 2*max(range(:,1))/ndivs(1);
    ylo = -1 + 2*min(range(:,2))/ndivs(2);
    yhi = -1 + 2*max(range(:,2))/ndivs(2);
    xsubdivs = nsubdivs(1);
    ysubdivs = nsubdivs(2);
    xalldivs = xdivs*xsubdivs;
    yalldivs = ydivs*ysubdivs;
    xallposts = xalldivs+1;
    yallposts = yalldivs+1;
    xx = linspace( xlo, xhi, xallposts );
    yy = linspace( ylo, yhi, yallposts );
    
    sl.pts = [ repmat( xx', yallposts, 1 ), reshape( repmat( yy, xallposts, 1 ), [], 1 ) ];
    
    % Make cells.
    u1x = 0:(xsubdivs-1);
    u1y = zeros(1,ysubdivs);
    u2x = xsubdivs + zeros(1,ysubdivs);
    u2y = 0:(ysubdivs-1);
    u3x = xsubdivs:-1:1;
    u3y = ysubdivs + zeros(1,xsubdivs);
    u4x = zeros(1,xsubdivs);
    u4y = ysubdivs:-1:1;
    u1 = u1x + u1y*xallposts;
    u2 = u2x + u2y*xallposts;
    u3 = u3x + u3y*xallposts;
    u4 = u4x + u4y*xallposts;
    
    totalpts = xallposts*yallposts;
    rowjump = xallposts*ysubdivs;
    origins = reshape( allsums( 0:xsubdivs:(xalldivs-xsubdivs), 1:rowjump:(totalpts-rowjump-xalldivs) ), [], 1 );
    
    v1 = allsums( origins, u1 );
    v2 = allsums( origins, u2 );
    v3 = allsums( origins, u3 );
    v4 = allsums( origins, u4 );
    sl.cellvxs = [ v1, v2, v3, v4 ];
    sl = deleteUnusedVerts( sl );
end

function c = allsums( a, b )
    c = repmat( a(:), 1, length(b) ) + repmat( b(:)', length(a), 1 );
end

function sl = XXcombinegrids( sl1, sl2, tol )
    numpts1 = size(sl1.pts,1);
    sl.pts = [ sl1.pts; sl2.pts ];
    width = max( size(sl1.cellvxs,2), size(sl1.cellvxs,2) );
    cellvxs2 = extendArray2( sl2.cellvxs, width );
    cellvxs2(cellvxs2>0) = cellvxs2(cellvxs2>0) + numpts1;
    sl.cellvxs = [ extendArray2( sl1.cellvxs, width ); cellvxs2 ];
    if nargin >= 3
        sl = combineDuplicateVerts( sl, tol );
    end
end

function sl = combineGrids( sls, tol )
% This uses only the pts and cellvxs fields of the arguments, and
% constructs only those in the result.

    if isempty(sls)
        sl = [];
        return;
    end
    
    ndims = size(sls(1).pts,2);
    npts = zeros(length(sls),1);
    ncells = zeros(length(sls),1);
    ncellvxs = zeros(length(sls),1);
    for i=1:length(sls)
        npts(i) = size(sls(i).pts,1);
        ncells(i) = size(sls(i).cellvxs,1);
        ncellvxs(i) = size(sls(i).cellvxs,2);
    end
    maxcellvxs = max( ncellvxs );
    pi = 0;
    ci = 0;
    sl.pts = zeros( sum(npts), ndims );
    sl.cellvxs = zeros( sum(ncells), maxcellvxs );
    for i=1:length(sls)
        sl.pts( (pi+1):(pi+npts(i)), : ) = sls(i).pts;
        sl.cellvxs( (ci+1):(ci+ncells(i)), 1:ncellvxs(i) ) = offsetnz( sls(i).cellvxs, pi );
        pi = pi + npts(i);
        ci = ci + ncells(i);
    end
    if nargin >= 2
        sl = combineDuplicateVerts( sl, tol );
    end
end

function a = offsetnz( a, offset )
    if offset ~= 0
        a(a~=0) = a(a~=0) + offset;
    end
end

function sl = makeCircularOrthogonalGrid( ndivs, nsubdivs, range )
% Make an orthogonal grid in a circle.
% NSUBDIVS IS UNIMPLEMENTED.

    if numel(ndivs)==1
        ndivs = [ ndivs ndivs ndivs ];
    end
    if numel(nsubdivs)==1
        nsubdivs = [ nsubdivs nsubdivs nsubdivs ];
    end
    if isempty(range)
        range = [zeros(1,length(ndivs)); ndivs];
    end
    xndivs = ndivs(1);
    yndivs = ndivs(2);
    xnsubdivs = nsubdivs(1);
    ynsubdivs = nsubdivs(2);
    % yndivs and all subdivs not implemented.

    sl = struct();
    cellwidth = 2/xndivs;
    nposts = xndivs+1;
    x = linspace( -1, 1, nposts );
    y = x;
    xx = repmat( x', nposts, 1 );
    yy = reshape( repmat( y, nposts, 1 ), [], 1 );
    pts = [ xx, yy ];
    
    e1 = (1:nposts^2)';
    e1(mod(e1,nposts)==0) = [];
    xedges = [ e1, e1+1 ];
    e2 = (1:nposts*(nposts-1))';
    yedges = [ e2, e2+nposts ];
    edges = [ xedges; yedges ];
    
    e1( (xndivs^2+1):end ) = [];
    cellvxs = [ e1, e1+1, e1+nposts+1, e1+nposts ];
    ce1 = (1:(xndivs^2))';
    ce4 = ((nposts*xndivs+1):(2*nposts*xndivs))';
    ce4(mod(ce4,nposts)==0) = [];
    celledges = [ ce1, ce4+1, ce1+xndivs, ce4 ];
    
    
    
    r = sqrt(sum(pts.^2,2));
    tol = 0.005*cellwidth;
    outerpts = r > 1+tol;
    innerpts = r < 1-tol;
    borderpts = ~(innerpts | outerpts);
    borderradius = r( borderpts );
    
    % Move all border points so as to lie exactly on the circle.
    pts(borderpts,:) = pts(borderpts,:)./repmat( borderradius, 1, 2 );
    
    outsidecells = all( outerpts( cellvxs ), 2 );
%     cellvxs = cellvxs( ~outsidecells, : );
    celledges = celledges( ~outsidecells, : );

    
    % Find all edges joining an outer point to an inner point.
    % For each such edge, add a new point, its intersection with the
    % circle.
    

    transverseedges = (outerpts(edges(:,1)) & innerpts(edges(:,2))) ...
                    | (innerpts(edges(:,1)) & outerpts(edges(:,2)));
    htransverse = edges(transverseedges,2) - edges(transverseedges,1) == 1;
    vtransverse = ~htransverse;
    transverseedgesi = find( transverseedges );
    tedges = edges(transverseedges,:);
    
    transversex = sqrt( 1 - pts( tedges(htransverse,1), 2 ).^2 );
    x1 = pts( tedges(htransverse,1), 1 );
    x2 = pts( tedges(htransverse,1)+1, 1 );
    xsignwrong = (transversex < x1) | (x2 < transversex);
    transversex(xsignwrong) = -transversex(xsignwrong);
    xintersections = [ transversex, pts( tedges(htransverse,1), 2 ) ];
    innerxpts = tedges(htransverse,1)+xsignwrong;
    nxedges = length(xintersections);
    newxedges = [ innerxpts, ((size(pts)+1) : (size(pts)+nxedges))' ];
    newxedges(xsignwrong,:) = newxedges(xsignwrong,[2 1]);
    
    
    transversey = sqrt( 1 - pts( tedges(vtransverse,1), 1 ).^2 );
    y1 = pts( tedges(vtransverse,1), 2 );
    y2 = pts( tedges(vtransverse,1)+nposts, 2 );
    ysignwrong = (transversey < y1) | (y2 < transversey);
    transversey(ysignwrong) = -transversey(ysignwrong);
    yintersections = [ pts( tedges(vtransverse,1), 1 ), transversey ];
    innerypts = tedges(vtransverse,1)+nposts*ysignwrong;
    nyedges = length(yintersections);
    newyedges = [ innerypts, ((size(pts)+nxedges+1) : (size(pts)+nxedges+nyedges))' ];
    newyedges(ysignwrong,:) = newyedges(ysignwrong,[2 1]);
    
    numoriginaledges = size(edges,1);
    edges = [ edges; newxedges; newyedges ];
    numoldpts = size(pts,1);
    pts = [ pts; xintersections; yintersections ];
    numnewpts = size(pts,1);
%     outerpts( (numoldpts+1):numnewpts ) = false;
    innerpts( (numoldpts+1):numnewpts ) = false;
    borderpts( (numoldpts+1):numnewpts ) = true;
    
    % Construct a reindexing of the edges, mapping every transverse edge
    % to the new edge, and every outside edge to zero.
    numoldedges = size(edges,1);
    numnewedges = numoldedges + nxedges + nyedges;
    edgereindex = (1:numnewedges)';
    edgereindex( transverseedgesi(htransverse) ) = ((numoriginaledges+1) : (numoriginaledges+nxedges))';
    edgereindex( transverseedgesi(vtransverse) ) = ((numoriginaledges+nxedges+1) : (numoriginaledges+nxedges+nyedges))';
    deletededges = ~any( innerpts( edges ), 2 );
    edgereindex(deletededges) = 0;
    
    % Reindex the cell edges.
    celledges = edgereindex( celledges );
    
    % Delete all cells with no remaining edges.
    celledges(all(celledges==0,2),:) = [];
    
    % Take all border points and all intersection points, and sort them by
    % angle.
    
    borderptindexes = find(borderpts);
    allborderpts = pts(borderpts,:);
    allborderangles = atan2( allborderpts(:,2), allborderpts(:,1) );
    [~,borderperm] = sort( allborderangles );
    borderptindexes = borderptindexes(borderperm);
%     allborderpts = pts(borderptindexes,:);
    
    % Add a new edge joining each consecutive pair of border edges,
    % anticlockwise.
    
    borderedges = [ borderptindexes, borderptindexes([2:end 1]) ];
    numinterioredges = size(edges,1);
%     numborderedges = size(borderedges,1);
    edges = [ edges; borderedges ];
    
    % For each cell that should acquire a border edge, insert that edge.
    % This may make some cells have five edges, so we first expand the
    % celledges array.
    celledges(:,5) = 0;
    reversededges = false(size(celledges));
    % A cell needs a border edge if it contains any of the new transverse
    % edges.
%     cellborderedges = celledges > numoriginaledges;
    edgespercell = 4;
%     nzedgespercell = sum( celledges ~= 0, 2 );
    for i=1:size(celledges,1)
        % Find where a border edge must be inserted.
        ce = celledges(i,1:edgespercell);
        if all(ce==0)
            continue;
        end
        re = [false false true true];
        re = re(ce ~= 0);
        ce = ce(ce ~= 0);
        ev = edges(ce,:);
        ev(re,:) = ev(re,[2 1]);
        insertindex = find( ev(:,2) ~= ev([2:end 1],1), 1 );
        if ~isempty( insertindex )
            % Find which border edge must be inserted.
            vx1 = ev(insertindex,2);
            vx2 = ev(mod(insertindex,length(ce))+1,1);
            % The border edge must be the one joining these two vertexes.
            addedborderedge = find(borderedges(:,1)==vx1);
            if borderedges(addedborderedge,2) ~= vx2
                % Error
                fprintf( 1, 'Error in finding border edge for cell %d: expected edge %d to be [%d %d] but found [%d %d].\n', ...
                    i, addedborderedge + numinterioredges, vx1, vx2, borderedges(addedborderedge,:) );
                xxxx = 1;
%                 error('Error in finding border edge for cell %d: expected edge %d to be [%d %d] but found [%d %d].\n', ...
%                     i, addedborderedge + numinterioredges, vx1, vx2, borderedges(addedborderedge,:) );
            end
            % Insert the border edge.
            ce = [ ce(1:insertindex), addedborderedge + numinterioredges, ce( (insertindex+1):end ) ];
            re = [ re(1:insertindex), false, re( (insertindex+1):end ) ];
        end
        reversededges(i,1:length(re)) = re;
        ce( (end+1):5 ) = 0;
        celledges(i,:) = ce;
        xxxx = 1;
    end
    
    
    
    % For each cell we need to find all its new edges (replacements of
    % transverse edges) and zero edges (edges that have been deleted
    % without being replaced).  Cells with none of these are left
    % unchanged.  For other cells, the vertexes of their nonzero edges
    % should form a cycle.
    
    extedges = [ [0 0]; edges ];
    vxpairs = extedges( celledges'+1, : );
    rev2 = reshape(reversededges',[],1);
    vxpairs( rev2, : ) = vxpairs( rev2, [2 1] );
    vxpairs = reshape( vxpairs, 5, [], 2 );
    cellvxs = vxpairs(:,:,1)';
    
    sl.pts = pts;
    sl.cellvxs = cellvxs;
    sl = deleteUnusedVerts( sl );
    sl = combineDuplicateVerts( sl, 1e-6 );
end

function sl = makeCircularRadialGrid( ndivs, nsubdivs, range )
% Make a circular target-like grid with R radii and C circles, where
% NDIVS = [ R, C ].

    sl = make2DGrid( ndivs, nsubdivs, range );
    
    theta = sl.pts(:,1)*pi;
    r = (sl.pts(:,2)+1)/2;
    ctheta = cos(theta);
    stheta = sin(theta);
    sl.pts(:,1) = ctheta.*r;
    sl.pts(:,2) = stheta.*r;
    sl = combineDuplicateVerts( sl, 1e-6 );
end

function [m,ok] = installGrid( m, sl, add )
    ok = true;
    if isVolumetricMesh(m)
        vxsPerFE = getNumVxsPerFE( m );
    else
        vxsPerFE = 3;
    end
    npts = size(sl.pts,1);
    sl.fe = zeros(npts,1);
    sl.febcs = zeros(npts,vxsPerFE);
    sl.bcerr = zeros(npts,1);
    sl.abserr = zeros(npts,1);
    for i=1:npts
        if (mod(i,20)==0)
            if teststopbutton(m)
                ok = false;
                return;
            end
        end
        [ sl.fe(i), sl.febcs(i,:), sl.bcerr(i), sl.abserr(i) ] = findFE( m, sl.pts(i,:) );
    end

    if ~add
        m.secondlayer = deleteSecondLayerCells( m.secondlayer );
        m.secondlayerstatic = newemptysecondlayerstatic();
    end
%     m.secondlayer.edges = 
    numoldcells = length(m.secondlayer.cells);
    numoldvxs = length(m.secondlayer.vxFEMcell);
    numnewcells = size(sl.cellvxs,1);
    numcells = size(sl.cellvxs,1);
    for i=1:numnewcells
        cvxs = sl.cellvxs(i,:);
        cvxs = cvxs(~isnan(cvxs));
        m.secondlayer.cells(numoldcells+i).vxs = numoldvxs + cvxs(cvxs~=0);
    end
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; sl.fe ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; sl.febcs ];
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; sl.pts ];

    if isVolumetricMesh(m)
        if ~isfield( m.secondlayer, 'surfaceVertexes' )
            m.secondlayer.surfaceVertexes = false(0,1);
        end
        m.secondlayer.surfaceVertexes = [ m.secondlayer.surfaceVertexes; false( length(m.secondlayer.vxFEMcell), 1 ) ];
    end
    m.secondlayer.cellcolor = [ m.secondlayer.cellcolor; ones( numcells, 3 ) ];
    m.secondlayer.side = [ m.secondlayer.side(:); true( numcells, 1 ) ];
    m.secondlayer.cloneindex = [ m.secondlayer.cloneindex(:); zeros( numcells, 1 ) ];
end

function plotsl( fig, sl )
    figure(fig);
    ax = gca;
    cla(ax);
    axis equal;
    hold on
    plotpts( ax, sl.pts, '.', 'MarkerSize', 20 );
    
    extpts = [ sl.pts; nan(1,size(sl.pts,2)) ];
    nanindex = size(sl.pts,1)+1;
    if isfield( sl, 'edges' )
        plotpts( ax, extpts( [sl.edges'; nanindex+zeros(1,size(sl.edges,1))], : ), '-' );
    end
    
    paths = cell(size(sl.cellvxs,1),1);
    
    scaling = 0.9;
    for i=1:size(sl.cellvxs,1)
        vi = sl.cellvxs(i,:);
        vi = vi(vi~=0);
        p = sl.pts(vi,:);
        meanp = repmat( sum(p,1)/size(p,1), size(p,1), 1 );
        p = meanp + scaling*(p - meanp);
        paths{i} = [p([1:end 1],:); nan(1,size(sl.pts,2))];
    end
    allpaths = cell2mat(paths);
    plotpts( ax, allpaths, '.-' );
    hold off
end

function reindex = reindexFromMap( retainedmap )
    retainedvxindexes = find(retainedmap);
    reindex = zeros(length(retainedmap),1);
    reindex(retainedvxindexes) = 1:length(retainedvxindexes);
end
