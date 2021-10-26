function gaussInfo = computeGaussInfo()
%mesh = computeGaussInfo( mesh )
%   Compute the gauss points in barycentric coordinates, and the values and
%   gradients of the shape functions there.

    gaussInfo.points = GaussQuadPoints();
    gaussInfo.N = calcN( gaussInfo.points );
    gaussInfo.gradN = gradN( gaussInfo.points );
end
