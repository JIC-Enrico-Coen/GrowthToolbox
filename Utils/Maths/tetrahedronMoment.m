function [moment,centroid,volume] = tetrahedronMoment( vxs, refpoint )
%[moment,centroid,volume] = tetrahedronMoment( vxs, origin )
%   Calculate the moment of inertia tensor M of a tetrahedron of uniform
%   density whose vertexes are given by the 4*3 array VXS, about the point
%   REFPOINT, a 1*3 array. The tetrahedron is considered to have unit
%   density. To obtain the moment for a tetrahedron of unit mass, divide
%   the moment by the volume.
%
%   REFPOINT defaults to the centroid of the tetrahedron.
%   The centroid and volume of the tetrahedron are also returned.
%
%   The formulas come from F. Tonon, "Explicit Exact Formulas for the 3-D
%   Tetrahedron Inertia Tensor in Terms of its Vertex Coordinates", J Math.
%   Stat. 1(1):8-11, 2004.
%
%   I have modified and extended his treatment in several ways.
%
%   I have corrected a mistake (his b and c were interchanged in some
%   places).
%
%   I have simplified his formulas to use matrix operations instead of
%   explicit subscripts.
%
%   I have confirmed that my implementation numerically agrees with the
%   example Tonon gives.
%
%   I have extended the calculation to allow the computation of the moment
%   about any reference point.
%
%   Some validity tests are given in testTetrahedronMoment.

    numdims = size(vxs,2);
    numvxs = size(vxs,1);
    
    volfactor = factorial(numdims);
    pp = ones(numvxs,numvxs) + eye(numvxs);
    centroid = mean(vxs,1);
    vxs = vxs - centroid;
    volume = abs( det( vxs(2:numvxs,:) - vxs(1,:) ) )/volfactor;
    vxpolynomials = vxs' * pp * vxs;
    moment = (trace(vxpolynomials)*eye(numdims) - vxpolynomials)*(volume/20);
    
    if (nargin >= 2) && ~isempty(refpoint) && (volume > 0)
        pointmoment = pointMassInertia( centroid - refpoint, volume );
        moment = moment + pointmoment;
    end
end
