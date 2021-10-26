function g = totalGrowth( G )
%g = totalGrowth( G )    Return the total growth given by the growth tensor G
%in 6-vector form. This is the determinant of the matrix representation of
%G.

    g = log( det( [ [ 1+G(1), G(6), G(5) ];
               [ G(6), 1+G(2), G(4) ];
               [ G(5), G(4), 1+G(3) ] ] ) );
end
