function perPoly = perVertextoperPolygon( polygons, perVx, method, whichpolys )
%perPoly = perVertextoperPolygon( polygons, perVx, whichpolys )
%   Given a quantity that is defined for each vertex of a polygon mesh,
%   calculate an equivalent quantity per polygon.  It is assumed that all
%   polygons have the same number of vertexes (because that is the only
%   case for which we need this operation in GFtbox).
%
%   method can be 'min', 'max', 'sum', 'mid', or 'ave' (the last two being
%   synonymous).
%
%   The per-vertex quantity can have any number of columns, and perPoly
%   will have the same number of columns. 

    valuesPerVertex = size(perVx,2);
    vxsPerPoly = size(polygons,2);
    selectPolys = nargin >=4;
    if valuesPerVertex==1
        if selectPolys
            perPoly = combineValues( perVx( polygons(whichpolys,:) ), method, 2 );
        else
            perPoly = combineValues( perVx( polygons ), method, 2 );
        end
    else
        if selectPolys
            perPoly = permute( combineValues( reshape( perVx( polygons(whichpolys,:)', : ), vxsPerPoly, [], valuesPerVertex ), method, 1 ), ...
                              [2,3,1] );
        else
            perPoly = permute( combineValues( reshape( perVx( polygons', : ), vxsPerPoly, [], valuesPerVertex ), method, 1 ), ...
                              [2,3,1] );
        end
    end
end
