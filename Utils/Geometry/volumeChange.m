function [coeffs,dv] = volumeChange( vxs, tris, displacements )
%[coeffs,dv] = volumeChange( vxs, tris, displacements )
%   VXS is an N*3 array of N points in space.
%   TRIS is a K*3 array of indexes into 1:N, specifying a set of triangles
%   whose corners are in VXS.
%   The triangle mesh so defined is assumed to enclose some space, and the
%   right-handed normal vectors point outwards.
%   DISPLACEMENTS, if present, is an N*3 set of displacements of the
%   vectors. These are assumed to be small in magnitude relative to the
%   lengths of the sides of the triangles.
%
%   We want to calculate the change in volume of the enclosed space due to
%   these displacements. To first order, the change in volume is a linear
%   combination of the components of the displacement vectors.
%
%   The COEFFS result is a row vector of N*3 values, such that if
%   displacements is transformed to an N*3 vector, listing its elements
%   row by row, i.e. in this order:
%
%       1 2 3
%       4 5 6
%       7 8 9
%       10 11 12 ...
%
%   then the dot product of these two vectors is the change in volume.
%
%   If displacements is given and the DV output is requested, DV will be
%   that dot product:
%
%       dv = dot( coeffs, reshape( displacements', 1, [] ) );

    numvxs = size(vxs,1);
    dims = 3;
    numdfs = numvxs * dims;
    vertexesPerTriangle = 3;
    numtris = size( tris, 1 );

    % DINDEXES indexes the components of DISPLACEMENTS, i.e. it looks like:
    %       1 2 3
    %       4 5 6
    %       7 8 9
    %       10 11 12 ...
    dindexes = reshape( 1:numdfs, dims, numvxs )';
    
    % DISPINDEXPERCORNER associates an index from DINDEXES with each
    % corner of each triangle, for each spatial dimension.
    dispIndexPerCorner = reshape( dindexes( tris', : ), vertexesPerTriangle, numtris, dims );

    % Get the right-handed normal vector and the area of each triangle.
    [areas,normals] = triangleareas( vxs, tris );
    
    % Calculate the scaled normals whose dot products with the displacement
    % at each corner give the change in volume due to the movement of each
    % triangle.
    areaNormalsPerCorner = repmat( shiftdim( (areas/3).*normals, -1 ), 3, 1, 1 );
    
    % Now we sum up all the elements of areaNormalsPerCorner that
    % correspond to each component of each displacement vector. These are
    % the coefficients we want.
    coeffs = sumArrayOverIndexes( dispIndexPerCorner, areaNormalsPerCorner, numdfs )';
    
    if (nargin >= 3) && (nargout >= 2)
        dv = dot( coeffs, reshape( displacements', 1, [] ) );
    end
end
