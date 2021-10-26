function isinside = insideSurface( s, v )
%isinside = insideSurface( s, v )
%   Determine whether v is inside or outside the closed surface s.  s is
%   assumed to have all its faces oriented so that the right-handed normals
%   point outwards.

    % Eliminate trivial cases.
    if isempty(s) ...
            || ~isfield( s, 'vertices' ) ...
            || isempty( s.vertices ) ...
            || ~isfield( s, 'faces' ) ...
            || isempty( s.faces )
        isinside = false;
        return;
    end

    % First we do a screening test to exclude all faces where either the Y
    % coords are all above that of v, or all below, and similarly for Z.

    yhi = s.vertices(:,2) > v(2);
    zhi = s.vertices(:,3) > v(3);
    yhifaces = yhi(s.faces);
    zhifaces = zhi(s.faces);
    
    okfaces = any(yhifaces,2) & any(~yhifaces,2) & any(zhifaces,2) & any(~zhifaces,2);
    % Typically, okfaces has at most 4 elements.

    % Now we do an exact test on each of these faces.
    
    % First get the face vertexes into a 3x3xN array, where the three
    % dimensions are the index of a vertex within the face, the coordinate
    % dimension, and the face index (in the range 1:length(okfaces)).
    facecoords = permute( reshape( s.vertices( s.faces(okfaces,:)', : ), 3, [], 3 ), [1 3 2] );
    
    % counts(1) will be the number of faces that v is on the inside side
    % of, counts(2) the number it is on the outside of.  For a convex
    % surface the only possibilities are [2,0], [1,1], and [0,0].  Only in
    % the first case is the point inside.
    counts = zeros(1,2);
    for i=1:size(facecoords,3)
        % Find the barycentric coords of v in this face, projecting
        % everything onto the YZ plane.  The X-line through v hits the
        % triangle if and only if these coordinates are all positive.  (Not
        % sure what to do about edge cases where the line exactly
        % intersects an edge or vertex.)
        bcs = baryCoordsN( facecoords(:,[2 3],i), v([2 3]) );
        if all( bcs>=0 )
            % The line through v parallel to the X axis hit this face.
            % Determine which side of the face v is on.
            tp = tripleProduct( facecoords(2,:,i) - facecoords(1,:,i), ...
                                facecoords(3,:,i) - facecoords(1,:,i), ...
                                v - facecoords(1,:,i) );
            ci = (tp>0) + 1;
            counts(ci) = counts(ci) + 1;
        end
    end

    % We are on the inside of the surface if and only if we are inside
    % more faces than we are outside.
    isinside = counts(1) ~= counts(2);
end

function tp = tripleProduct( v1, v2, v3 )
    tp = dot( v1, cross( v2, v3 ) );
end