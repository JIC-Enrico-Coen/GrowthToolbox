function a = triangleAngles( tri )
%a = triangleAngles( tri )
%   TRI is a 3*3 matrix of row vectors, the vertexes of a triangle.
%   A is set to the angles of the triangle, as a column vector.

    edges = tri([2 3 1],:) - tri([3 1 2],:);
    edgsqs = sum( edges.*edges, 2 );
    if edgsqs(1)==0
        a = [ 0, pi/2, pi/2 ];
    elseif edgsqs(2)==0
        a = [ pi/2, 0, pi/2 ];
    elseif edgsqs(3)==0
        a = [ pi/2, pi/2, 0 ];
    else
        numers = edgsqs([2 3]) + edgsqs([3 1]) - edgsqs([1 2]);
        edglens = sqrt(edgsqs);
        denoms = edglens([2 3]) .* edglens([3 1]);
        cosines = (numers./denoms)/2;
        a = acos(cosines);
        a = [ a; pi-sum(a) ];
    end
end
