function D = SemiOrthotropicStiffnessMatrix( a1, a3, b1, b2, b3, c1, c2 )
    a2 = a1;
    c3 = 0;
    b3 = a1;
    D = [ a1 b3 b2 0  0  0;
          b3 a2 b1 0  0  0;
          b2 b1 a3 0  0  0;
          0  0  0  c1 0  0;
          0  0  0  0  c2 0;
          0  0  0  0  0  c3 ];
end
