function v = make6vector( m )
%v = make6vector( m )  Convert a symmetric 3*3 matrix into a 6*1 vector.
%If m is 2*2 it will be treated as a 3*3 matrix with row 3 and column 3 all
%zero.
%
%m can also have size 3*3*N or 2*2*N, and all N matrices will be converted,
%giving an N*6 matrix.

    symmetrycount = 2;
    if size(m,1)==3
        v = [ m(1,1,:), m(2,2,:), m(3,3,:), symmetrycount*[m(2,3,:), m(3,1,:), m(1,2,:)] ];
    else
        v = [ m(1,1,:), m(2,2,:), zeros(size(m,3),3), symmetrycount*m(1,2,:) ];
    end
    v = permute(v,[3 2 1]);
end
