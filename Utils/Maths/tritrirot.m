function [r,r1] = tritrirot( oldnodes, oldnormals, newnodes, newnormals, tricellvxs )
%r = tritrirot( oldnodes, newnodes, tricellvxs )
%   OLDNODES and NEWNODES are the old and new positions of a set of N
%   nodes, each an N*3 matrix.
%   TRICELLVXS is a set of M triangles on those nodes, an M*3 matrix.
%   R is set to an M*3*3 array containing M rotation matrices that rotate
%   the old triangles to the same orientation as the new.

    v12 = oldnodes( tricellvxs(:,2), : ) - oldnodes( tricellvxs(:,1), : );
    v13 = oldnodes( tricellvxs(:,3), : ) - oldnodes( tricellvxs(:,1), : );
    w12 = newnodes( tricellvxs(:,2), : ) - newnodes( tricellvxs(:,1), : );
    w13 = newnodes( tricellvxs(:,3), : ) - newnodes( tricellvxs(:,1), : );
    numtri = size(tricellvxs,1);
    r1 = zeros(3,3,numtri);
    r = zeros(3,3,numtri);
    for i = 1:numtri
        w = [w12(i,:);w13(i,:);newnormals(i,:)];
        v = [v12(i,:);v13(i,:);oldnormals(i,:)];
        r1(:,:,i) = inv(v)*w;
        r(:,:,i) = extractRotation( r1(:,:,i) );
    end
end

