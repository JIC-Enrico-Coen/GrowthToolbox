function v = lineCutByPolygon( pv, vin, vout )
%v = lineCutByPolygon( pv, vin, vout )
%   PV is a polygon represented by an N*2 array, which is the N vertexes in
%   order round the polygon (it does not matter which way).
%   VIN is a point known to be inside the polygon, and VOUT a point
%   outside, represented as column vectors.
%   The result V is a point where the line V1 V2 intersects the boundary
%   of the polygon, represented as a column vector.
    for i=1:size(pv,1)
        if i==1
            [b,v] = lineIntersection( pv(size(pv,1),:)', pv(1,:)', vin, vout );
        else
            [b,v] = lineIntersection( pv(i-1,:)', pv(i,:)', vin, vout );
        end
        if b, return; end
    end
  % Error: no intersection found.
    v = [];
end
