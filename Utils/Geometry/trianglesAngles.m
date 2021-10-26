function a = trianglesAngles( tri )
%a = trianglesAngles( tri )
%   TRI is a 3*3*N matrix of row vectors, the vertexes of N triangles.
%   A is set to the angles of all the triangles, as a 3*N matrix.
%   The triangles are assumed to be all non-degenerate.

    edges = tri([2 3 1],:,:) - tri([3 1 2],:,:);
    edgsqs = sum( edges.*edges, 2 );
    numers = edgsqs([2 3],:) + edgsqs([3 1],:) - edgsqs([1 2],:);
    edglens = sqrt(edgsqs);
    denoms = edglens([2 3],:) .* edglens([3 1],:);
    cosines = (numers./denoms)/2;
    a = acos(cosines);
    a = [ a; pi-sum(a,1) ];
end
