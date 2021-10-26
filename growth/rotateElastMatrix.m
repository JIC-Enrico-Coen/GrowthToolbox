function rotD = rotateElastMatrix( D, J )
%rotD = rotateElastMatrix( D, J )    D is an elasticity tensor in
%6-matrix form.  The result is the rotation of D by J, a rotation matrix.

    J6 = rotmatTo6mat4( J );
    rotD = J6 * D * J6';
end
