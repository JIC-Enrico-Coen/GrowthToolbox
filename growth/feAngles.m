function a = feAngles( m, ci )
%a = feAngles( m, ci )
%   Compute the angles of the finite element ci.

    a = triangleAngles( m.nodes( m.tricellvxs( ci, : ), : ) );
end
