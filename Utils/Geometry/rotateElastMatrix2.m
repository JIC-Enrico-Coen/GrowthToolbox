function rotD = rotateElastMatrix2( D, J )
%rotD = rotateElastMatrix( D, J )    D is a 2D elasticity tensor in
%3-matrix form.  The result is the rotation of D by J, a 2D rotation matrix
%or a rotation angle.

    if numel(J)==1
        c = cos(J);
        s = sin(J);
        J = [ [c -s]; [s c] ];
    end
    J3 = rotmat2To3mat( J );
    rotD = J3 * D * J3';
end
