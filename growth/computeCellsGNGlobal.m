function gnGlobal = computeCellsGNGlobal( v, gaussInfo )
%gnGlobal = computeCellsGNGlobal( v, gaussInfo )
%   Compute the gradients of the shape functions in the global frame, at
%   every gauss point of every cell.  v is the set of vertexes of all
%   cells, as a 3*6*n array: v(:,:,i) is the set of 6 vertexes of cell i.
%   the globally constant Gauss point information in isoparametric
%   coordinates.
% NEVER USED.

 %  numCells = size(v,3);
 %  numGaussPoints = 6;
 %  repmat( gaussInfo.points, [1,1,numCells] );
    gnGlobal = zeros(3,6,numGaussPoints);
    J = PrismJacobians( v, gaussInfo.points );
  % J = inv3n(J);  % Only six matrices, so this is slower.
    for i=1:size(J,3)
        J(:,:,i) = inv(J(:,:,i));
    end
  % gnGlobal = mul3n( J, gaussInfo.gradN );  % Only six matrices, so
                                             % this is slower.
    for gi=1:numGaussPoints
        gnGlobal(:,:,gi) = J(:,:,gi)' * gaussInfo.gradN(:,:,gi);
    end
end
