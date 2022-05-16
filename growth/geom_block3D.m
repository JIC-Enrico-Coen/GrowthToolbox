function [vxs,vxsets,s,ok,g] = geom_block3D( varargin )
%[vxs,vxsets] = geom_block3Da( m, ... )
%   Make the geometry for of an axis-aligned rectangular block divided
%   into volumetric finite elements. Only vertexes and  the tuples that
%   form the elements are returned.
%
%   Options:
%
%   'size': A 3-element vector, default [2 2 2].  This specifies the
%       dimensions of the block.
%
%   'xwidth', 'ywidth', 'zwidth': Alternative way of specifying the size.
%       If the 'size' option is not given, it defaults to
%       [ xwidth, ywidth, zwidth ].
%
%   'divisions': A 3-element vector of positive integers, default [2 2 2].
%       This specifies how many finite elements it is divided into along
%       each dimension.
%
%   'xdivs', 'ydivs', 'zdivs': Alternative way of specifying the number of
%       finite elements each way. If the 'divisions' options is not given,
%       it defaults to [ xdivs, ydivs, zdivs ].
%
%   'position': A 3-element vector, default [0 0 0]. This specifies the
%       position of the centre of the block. 
%
%   'type': A finite element type.  Possibilities are 'T4Q' (the default),
%       and various others implemented.  'H8' specifies that the block is
%       to be made of linear hexahedra. 'T4' and 'T4Q' specify linear or
%       quadratic tetrahedra respectively (combining in fives or
%       twenty-fours to make blocklets).  'P6' specifies linear pentahedra
%       (combining in pairs to make blocklets).
%
%   'cubedivmethod': This is either 5 or 24, or the string '5' or '24'.
%       This applies only when 'type' is 'T4' or 'T4Q', and specifies which
%       of two methods of dividing each cube into tetrahedra is to be used.
%       '5' divides the cube into 5 tetrahedra, a central one spanning four
%       alternating vertexes, plus 4 tetrahedral caps. '24' divides each
%       face by its diagonals into 4 triangles, then connects each triangle
%       to the centre of the cube to give 24 tetrahedra. This uses several
%       times as many vertexes. For a block divided into 10x10x10
%       blocklets, the number of vertexes for '5' is 1331, and for '24' it
%       is 5361, a ratio of about 4 to 1.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK3D,
%           LEAF_SPHERE3D, LEAF_ICOSAHEDRON3D.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
%     setGlobals();
    s = defaultfields( s, ...
        'xwidth', 2, ...
        'ywidth', 2, ...
        'zwidth', 2, ...
        'xdivs', 2, ...
        'ydivs', 2, ...
        'zdivs', 2 );
    s = defaultfields( s, ...
        'size', [ s.xwidth, s.ywidth, s.zwidth ], ...
        'divisions', [ s.xdivs, s.ydivs, s.zdivs ], ...
        'position', [0 0 0], ...
        'type', 'T4Q', ...
        'cubedivmethod', 5 ); % Possibilities are 5 or 24 (or the strings '5' or '24').

    % We remove 'thickness' because this parameter is not applicable to
    % volumetric  meshes.  This is just a hack to cope with the fact that
    % GFtbox always supplies the thickness value from the GUI, even for
    % volumetric meshes.
    s = safermfield( s, 'xwidth', 'ywidth', 'zwidth', 'xdivs', 'ydivs', 'zdivs', 'thickness' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'size', 'divisions', 'position', 'type', 'cubedivmethod' );
    if ~ok, return; end
    
    if ischar(s.cubedivmethod)
        s.cubedivmethod = str2double( s.cubedivmethod );
    end

    locorner = s.position-s.size/2;
    hicorner = s.position+s.size/2;
    isQuadElement = strcmp( s.type, 'H8Q' ) || strcmp( s.type, 'T4Q2' );
    if isQuadElement
        segmentsperFE = [2 2 2];
    else
        segmentsperFE = [1 1 1];
    end
    numvals = s.divisions.*segmentsperFE + 1;
    xvals = linspace( locorner(1), hicorner(1), numvals(1) );
    yvals = linspace( locorner(2), hicorner(2), numvals(2) );
    zvals = linspace( locorner(3), hicorner(3), numvals(3) );
    
    allx = repmat( xvals(:), numvals(2)*numvals(3), 1 );
    ally = reshape( repmat( yvals, numvals(1), numvals(3) ), [], 1 );
    allz = reshape( repmat( zvals, numvals(1)*numvals(2), 1 ), [], 1 );
    vxs = [ allx, ally, allz ];
    dxi = segmentsperFE(1);
    dyi = numvals(1)*segmentsperFE(2);
    dzi = dyi*numvals(2)*segmentsperFE(3);
    if isQuadElement
        base = 0:segmentsperFE(1);
        relvxi = base;
        relvxi = reshape( repmat( relvxi', 1, segmentsperFE(2)+1 ) + repmat( base*numvals(1), length(relvxi), 1 ), 1, [] );
        relvxi = reshape( repmat( relvxi', 1, segmentsperFE(3)+1 ) + repmat( base*numvals(1)*numvals(2), length(relvxi), 1 ), 1, [] );
    else
        relvxi = [0, dxi, dyi, dxi+dyi];
        relvxi = [ relvxi, relvxi+dzi ];
    end
    vstarts1 = repmat( segmentsperFE(1)*(0:(s.divisions(1)-1))', s.divisions(2)*s.divisions(3), 1 );
    vstarts2 = reshape( repmat( numvals(1)*segmentsperFE(2)*(0:(s.divisions(2)-1)), s.divisions(1), s.divisions(3) ), [], 1 );
    vstarts3 = reshape( repmat( numvals(1)*numvals(2)*segmentsperFE(3)*(0:(s.divisions(3)-1)), s.divisions(1)*s.divisions(2), 1 ), [], 1 );
    vstarts = 1 + vstarts1 + vstarts2 + vstarts3;
    vxsets = repmat( vstarts, 1, length(relvxi) ) + repmat( relvxi, length(vstarts), 1 );
    numcubevxs = prod( numvals );

    flipAlternateCubes = (s.cubedivmethod ~= 24);
    if flipAlternateCubes
        ei = 0;
        for i=1:s.divisions(3)
            % The mirroring of cube vertex indexing is so that if we subdivide
            % each cube into tetrahedra, the divisions that appear on the cube
            % faces will be consistent for cubes sharing the same face.
            % If we are not subdividing, or if we are subdividing into
            % pentahedra, then there is no need for mirroring, but we do it in
            % all cases anyway.
            px = flipCuboidIndexes( 3*mod(i-1,2), segmentsperFE+1 );
            for j=1:s.divisions(2)
                py = px( flipCuboidIndexes( 2*mod(j-1,2), segmentsperFE+1 ) );
                % py = px( flipCubeIndexes( mod(j-1,2) ) );
                for k=1:s.divisions(1)
                    pz = py( flipCuboidIndexes( 1*mod(k-1,2), segmentsperFE+1 ) );
                    % pz = py( flipCubeIndexes( mod(k-1,2) ) );
                    ei = ei+1;
                    vxsets(ei,:) = vxsets( ei, pz );
                end
            end
        end
    end
    
    switch s.type
        case 'H8'
            % Nothing.
        case 'H8Q'
            % Nothing.
        case { 'T4', 'T4Q' }
            switch s.cubedivmethod
                case 5
                    % Make a new version of vxsets dividing each cube into
                    % 5 tetrahedra.
                    % For the vertexes of a cube numbered 1 to 8, the tetrahedra
                    % vertex sets are given by subindexes:
                    subindexes = [ 2 4 1 6; 3 1 4 7; 5 1 6 7; 8 4 7 6; 1 4 7 6 ]';
                    % These are then applied to each of the cubes:
                    vxsets = reshape( vxsets( :, subindexes )', size( subindexes, 1 ), [] )';
                case 24
                    % Make a new version of vxsets dividing each cube into
                    % 24 tetrahedra. This involves creating new vertexes at
                    % the face centres and cube centres.
                    numcubes = size( vxsets, 1 );
                    bits = logical( [ 0 0 0;
                                      1 0 0;
                                      0 1 0;
                                      1 1 0;
                                      0 0 1;
                                      1 0 1;
                                      0 1 1;
                                      1 1 1 ] );
                    % Construct the six faces of the basic cube, listing
                    % their vertexes so that by the right-hand rule, their
                    % normals all point inwards. This is necessary to
                    % ensure that the resulting tetrahedra have their
                    % vertexes correctly listed according to the right-hand
                    % rule.
                    f = [ find(~bits(:,1)), ...
                          find(bits(:,1)), ...
                          find(~bits(:,2)), ...
                          find(bits(:,2)), ...
                          find(~bits(:,3)), ...
                          find(bits(:,3)) ];
                    f(:,[1 4 5]) = f([1 2 4 3],[1 4 5]);
                    f(:,[2 3 6]) = f([2 1 3 4],[2 3 6]);
                    
                    % The extra vertexes of the basic cube are listed
                    % immediately after the corner vertexes, in the order
                    % -x, +x, -y, +y, -z, +z, centre.
                    facecentres = 9:14;
                    bodycentre = 15;
                    tetraspercube = 24;
                    
                    % tripertetra lists the faces of the 24 tetrahedra that
                    % lie on the surface of the cube, in the order: cube
                    % edge ends, then face centre.
                    tripertetra = reshape( f([1 2 2 3 3 4 4 1], :), 2, 4, 6 );
                    fcpertri = reshape( repmat( facecentres, 4, 1 ), 1, 4, 6 );
                    tripertetra = [tripertetra;fcpertri];
                    tripertetra = reshape( tripertetra, 3, 24 );
                    % The cube centre is then added to make the tetrahedra
                    % into which the basic cube is divided.
                    subindexes = [ tripertetra; bodycentre+zeros(1,24) ]';
                    
                    % The following calculations are split up into stages to
                    % facilitate debugging.
                    
                    % We want to find the set of unique face centres.
                    % Get the set of all cube faces.
                    fv1 = reshape( vxsets(:,f), numcubes, 4, 6 );
                    % Rearrange the data into a 4*N array, one column for
                    % each face.
                    fv2 = permute( fv1, [2, 3, 1] );
                    fv3 = reshape( fv2, 4, [] );
                    % Sort each face into ascending order, so that shared
                    % faces will have identical vertex lists.
                    fv4 = sort( fv3, 1 );
                    % Find the unique faces.
                    [fv5,~,ic] = unique( fv4', 'rows', 'stable' );
                    % Calculate their centres.
                    fcv1 = reshape( vxs( fv5', : ), 4, size(fv5,1), 3 );
                    fcv2 = mean( fcv1, 1 );
                    facecentrevxs = shiftdim( fcv2, 1 ); % One vertex for each unique face.
                    
                    % Calculate the cube centres. These can be found as the
                    % midpoint of the line between any two opposite face
                    % centres. The commented out code alternatively uses
                    % the -y and +y, or -z and +z faces, and provides a
                    % check that these indeed give identical cube centres
                    % up to rounding error.
                    ic2 = reshape( ic, 6, numcubes );
                    ic3x = ic2([1 2],:); % Use the -x and +x face centres.
%                     ic3y = ic2([3 4],:); % Use the -y and +y face centres.
%                     ic3z = ic2([5 6],:); % Use the -z and +z face centres.
                    % Apart from rounding errors, ic3, ic3y, and ic3z
                    % should be identical.
                    cv1 = facecentrevxs(ic3x,:)'; % 3 x (2 x numcubes). One vertex for each -x and +x face of each cube.
%                     cv1y = facecentrevxs(ic3y,:)'; % 3 x (2 x numcubes). One vertex for each -x and +x face of each cube.
%                     cv1z = facecentrevxs(ic3z,:)'; % 3 x (2 x numcubes). One vertex for each -x and +x face of each cube.
                    cv2 = reshape( cv1, 3, 2, numcubes );
%                     cv2y = reshape( cv1y, 3, 2, numcubes );
%                     cv2z = reshape( cv1z, 3, 2, numcubes );
                    % Get the cube centres.
                    cubecentrevxs = reshape( mean( cv2, 2 ), 3, numcubes )'; % Cube centres.
%                     cubecentrevxs_y = reshape( mean( cv2y, 2 ), 3, numcubes )'; % Cube centres.
%                     cubecentrevxs_z = reshape( mean( cv2z, 2 ), 3, numcubes )'; % Cube centres.
%                     max(abs(cubecentrevxs(:)-cubecentrevxs_y(:)))
%                     max(abs(cubecentrevxs(:)-cubecentrevxs_z(:)))
%                     xxxx = 1;

                    % Augment vxs by vertically appending the face centres
                    % andcube centres.
                    vxs1 = [ vxs; facecentrevxs; cubecentrevxs ];
                    % Augment vxsets by horizontally appending the indexes
                    % of the face centres and cube centres.
                    numfacecentres = size( fv5, 1 );
                    vxsets1 = [ vxsets, numcubevxs+ic2', (numcubevxs+numfacecentres)+(1:numcubes)' ]; % numcubes x 15
                    vxsets2 = reshape( vxsets1( :, subindexes' )', 4, tetraspercube * numcubes )';
                    
                    % Copy the results back to the output arguments.
                    vxsets = vxsets2;
                    vxs = vxs1;
            end
        case 'T4Q2'
            % The cubes are quadratic, with vertexes 1:27.
            % The tetrahedron vertex sets for the basic quadratic cube are
            % given by subindexes:
            subindexes = [ 1 2 3 4 5 7 10 11 13 19;
                           9 8 7 6 5 3 18 17 15 27;
                           21 12 3 24 15 27 20 11 23 19
                           25 16 7 22 13 19 26 17 23 27
                           3 5 7 11 13 19 15 17 23 27 ]';
            % These are then applied to each of the cubes:
            vxsets = reshape( vxsets( :, subindexes )', size( subindexes, 1 ), [] )';
        case 'P6'
            % Make a new version of vxsets dividing each cube into two
            % pentahedra.
            % For the vertexes of a cube numbered 1 to 8, the pentahedron
            % vertex sets ar given by subindexes:
            subindexes = [ 1 2 4 5 6 8; 1 4 3 5 8 7 ]';
            % These are then applied to each of the cubes:
            vxsets = reshape( vxsets( :, subindexes )', size( subindexes, 1 ), [] )';
        otherwise
            % Type not recognised, cannot build mesh.
            fprintf( 1, '%s: Unknown or unsupported finite element type ''%s''.\n', mfilename(), s.type );
            return;
    end
    
    if nargout >= 5
        g = Geometry3D( 'vxs', vxs, 'vxsets', vxsets );
    end
end

