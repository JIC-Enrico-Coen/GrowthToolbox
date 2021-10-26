function [gnGlobal,detJ] = computeCellGNGlobal( v, gaussInfo )
%gnGlobal = computeCellGNGlobal( v, gaussInfo )
%   Compute the gradients of the shape functions in the global frame, at
%   every gauss point.  v is the set of vertexes of the cell, gaussInfo is
%   the globally constant Gauss point information in isoparametric
%   coordinates.

  % global gGAUSS_INFO  % Slower than passing gaussInfo as an argument.
  
    numGaussPoints = 6;
    gnGlobal = zeros(3,6,numGaussPoints);
    J = PrismJacobians( v, gaussInfo.points );
  % J = inv3n(J);  % Only six matrices, so this is slower.
    J1 = zeros(size(J));
    detJ = zeros(size(J,3),1);
    for i=1:size(J,3)
        J1(:,:,i) = inv(J(:,:,i));
        detJ(i) = det(J(:,:,i));
    end
  % gnGlobal = mul3n( J, gaussInfo.gradN );  % Only six matrices, so
                                             % this is slower.
    for gi=1:numGaussPoints
        gnGlobal(:,:,gi) = J1(:,:,gi)' * gaussInfo.gradN(:,:,gi);
    end
end
