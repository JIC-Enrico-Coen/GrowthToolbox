function D = OrthotropicStiffnessMatrix( a1, a2, a3, b1, b2, b3, c1, c2, c3 )
    D = [ a1 b3 b2 0  0  0;
          b3 a2 b1 0  0  0;
          b2 b1 a3 0  0  0;
          0  0  0  c1 0  0;
          0  0  0  0  c2 0;
          0  0  0  0  0  c3 ];
end
