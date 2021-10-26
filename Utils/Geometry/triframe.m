function frame = triframe( t )
%frame = triframe( t )    Calculate a right-handed orthonormal frame of
%reference for a triangle t, such that the third axis is the triangle
%normal, and the first is one of its edges.
%The vertices of the triangle are the rows of t.
    n3 = trinormal(t);
    n3 = n3/norm(n3);
    n1 = t(2,:)-t(1,:);
    n1 = n1/norm(n1);
    n2 = crossproc2(n3,n1);
    frame = [n1;n2;n3];
end

    