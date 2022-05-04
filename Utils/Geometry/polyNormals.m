function [pn,vn] = polyNormals( vxs, polys )
%[cn,vn] = polyNormals( vxs, polys )
%   Calculate normal vectors to the specified polygons.
%   VXS is an N*3 array of vertex coordinates.
%   POLYS is a cell array of P tuples of vertexes that make the polygons.
%   PN is a P*3 array of the right-handed normals to the polygons.
%   VN is an array of the vertex normals of the polygons.

%cn = biocellNormals( m, cis )
%   Calculate normal vectors to the cells of M listed in CIS (by default,
%   all of them).
%[cn,vn] = biocellNormals( m, cis )
%   Calculate cell normals as above, and also vertex normals.

    if isempty(vxs) || isempty( polys )
        pn = zeros(0,3);
        vn = zeros(0,3);
    else
        np = length(polys);
        pn = zeros(np,3);
        for ci = 1:np
            cvxs = polys{ci};
            [c,p,flatness,planarity,v,d] = bestFitPlane( vxs(cvxs,:), 'area' );
            pn(ci,:) = p;
        end
        
        if nargout >= 2
            vn = zeros( size(vxs) );
            nvn = zeros( size(vxs,1), 1 );
            for ci = 1:np
                cvxs = polys{ci};
                vn( cvxs, : ) = vn( cvxs, : ) + pn(ci,:);
                nvn( cvxs ) = nvn( cvxs )+1;
            end
            vn = vn ./ nvn;
            vn = vn ./ sqrt(sum(vn.^2,2));
            vn(isnan(vn)) = 0;
        end
    end
end
