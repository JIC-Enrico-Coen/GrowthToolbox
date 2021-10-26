function area = polyarea3( x, y, z, dim )
% POLYAREA3 Area of polygon in 3D space.
%    POLYAREA3(X,Y,Z) returns the area of the polygon specified by
%    the vertices in the vectors X, Y, and Z.  If X, Y, and Z are matrices
%    of the same size, then POLYAREA3 returns the area of
%    polygons defined by the columns of X, Y, and Z.  If X, Y, and Z are
%    arrays, POLYAREA3 returns the area of the polygons in the
%    first non-singleton dimension of X, Y, and Z.  
% 
%    POLYAREA3(X,Y,Z,DIM) returns the area of the polygons specified
%    by the vertices in the dimension DIM.
%
%    POLYAREA3(M), where M is an N*3 matrix, is equivalent to
%    POLYAREA3( M(:,1), M(:,2), M(:,3), 1 ).
%
%    If the polygon is not flat, the area computed is the total area of all
%    the triangles formed by the centroid of the vertices and every
%    consecutive pair of vertices of the polygon.
% 
%    Based on the Matlab code for POLYAREA.
%
%    See also: POLYAREA.

if nargin==1
    centroid = sum(x,1)/size(x,1);
    for i=1:size(x,1)
        x(i,:) = x(i,:) - centroid;
    end
    crosses = cross( x, x( [2:size(x,1) 1], : ), 2 );
    area = sum(sqrt(sum(crosses.*crosses,2)))/2;
    return;
end

if nargin==2 
  error('MATLAB:polyarea3:NotEnoughInputs', 'Not enough inputs.'); 
end

if ~isequal(size(x),size(y)) 
  error('MATLAB:polyarea3:XYSizeMismatch', 'X and Y must be the same size.'); 
end

if ~isequal(size(x),size(z)) 
  error('MATLAB:polyarea3:XZSizeMismatch', 'X and Z must be the same size.'); 
end

if nargin==3
  [x,nshifts] = shiftdim(x);
  y = shiftdim(y);
  z = shiftdim(z);
elseif nargin==4
  perm = [dim:max(length(size(x)),dim) 1:dim-1];
  x = permute(x,perm);
  y = permute(y,perm);
  z = permute(z,perm);
end

if ~isempty(x),
    siz = size(x);
    s1 = siz(1);
    cx = sum(x,1)/s1;
    cy = sum(y,1)/s1;
    cz = sum(z,1)/s1;
    for i=1:s1
        x(i,:) = x(i,:) - cx;
        y(i,:) = y(i,:) - cy;
        z(i,:) = z(i,:) - cz;
    end
    crossx = y([2:siz(1) 1],:) .* z - z([2:siz(1) 1],:) .* y;
    crossy = z([2:siz(1) 1],:) .* x - x([2:siz(1) 1],:) .* z;
    crossz = x([2:siz(1) 1],:) .* y - y([2:siz(1) 1],:) .* x;
    area = sum(sqrt(abs(crossx.*crossx + crossy.*crossy + crossz.*crossz)),1)/2;
    area = reshape( area, [1 siz(2:end)] );
else
	area = sum(x); % SUM produces the right value for all empty cases
end

if nargin==3
  area = shiftdim(area,-nshifts);
elseif nargin==4
  area = ipermute(area,perm);
end

end

