function s = solve22( A, B, C, D, E, F )
%s = solve22( A, B, C, D, E, F )    Solve the equations
% ( A B )     ( E )
% (     ) s = (   )
% ( C D )     ( F )

    det = A*D-B*C;
    s = [ D*E-B*F; A*F-E*C ]/det;
end
