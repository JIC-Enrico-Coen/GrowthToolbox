function [G,Gbend,JG,JGbend] = tensorsFromDisplacements( vxs, d )
%[G,Gbend,J] = tensorsFromDisplacements( vxs, d )
% NEVER USED.
    
    % Calculate a tensor and a frame for top and bottom.
    % Both of these tensors will have zero values along the normal.
    % Use the normal displacements to obtain the normal value.
    % Convert these to growth and bend tensors.  Properly done, this
    % requires converting both to the global frame, taking the sum and
    % difference, then finding the principal axes and components of each
    % and ordering the axes appropriately.
    
    [G1local,J1] = tensorsFrom3Displacements( vxs([1,3,5],:), d([1,3,5],:) );
    [G2local,J2] = tensorsFrom3Displacements( vxs([2,4,6],:), d([2,4,6],:) );
    G1global = rotateTensor( [ G1local, 0, 0, 0, 0 ], J1 );
    G2global = rotateTensor( [ G2local, 0, 0, 0, 0 ], J2 );
    Gglobal = (G1global+G2global)/2;
    Bglobal = (G2global-G1global)/2;
    [G,JG] = tensorComponents( Gglobal );
    [Gbend,JGbend] = tensorComponents( Bglobal );
end
