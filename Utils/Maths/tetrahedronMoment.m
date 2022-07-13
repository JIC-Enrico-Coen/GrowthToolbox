function [m,centroid,volume] = tetrahedronMoment( vxs, refpoint )
%[m,centroid,volume] = tetrahedronMoment( vxs, origin )
%   Calculate the moment of inertia tensor M of a tetrahedron of uniform
%   density whose vertexes are given by the 4*3 array VXS, about the point
%   REFPOINT. The tetrahedron is considered to have unit density.
%
%   REFPOINT defaults to the centroid of the tetrahedron.
%   The centroid and volume of the tetrahedron are also returned.
%
%   The formulas come from F. Tonon, "Explicit Exact Formulas for the 3-D
%   Tetrahedron Inertia Tensor in Terms of its Vertex Coordinates", J Math.
%   Stat. 1(1):8-11, 2004. I have corrected a mistake, simplified them
%   to make their structure clearer, and confirmed that they numerically
%   agree with the example he gives. I have also extended the calculation
%   to allow the computation of the moment about any reference point.

% We have tried to make this more general than the three-dimensional case,
% but the validity of this is unclear, for two reasons. One is the magic
% number 20. How does this depend on the dimensionality? The other is that
% a two-dimensional lamina still has a three-dimensional inertia tensor,
% not merely one-dimensional.

    numdims = size(vxs,2);
    numvxs = size(vxs,1);
    volfactor = factorial(numdims);
    pp = ones(numvxs,numvxs) + eye(numvxs);
    centroid = mean(vxs,1);
%     vxpolynomials2 = vxs' * pp * vxs;
    vxs = vxs - centroid;
    volume = abs( det( vxs(2:numvxs,:) - vxs(1,:) ) )/volfactor;
    vxpolynomials = vxs' * pp * vxs;
    m = (trace(vxpolynomials)*eye(numdims) - vxpolynomials)*(volume/20);
%     m2 = (trace(vxpolynomials2)*eye(3) - vxpolynomials2)*(volume/20);
%     m2-m
    
    if (nargin >= 2) && ~isempty(refpoint) && (volume > 0)
        pointmoment = pointMassInertia( centroid - refpoint, volume );
        m = m + pointmoment;
    end
end