function [svx,se,sf,svol] = getSurfaceElements( volcells )
%[svx,se,sf,svol] = getSurfaceElements( volcells )
%   Determine which vertexes, edges, faces, and volumes of volcells are on
%   the surface. the results are N*1 boolean maps.

    numfaces = getNumberOfVolFaces( volcells );
    numedges = getNumberOfVolEdges( volcells );
    fv = getFaceVols( volcells );
    sf = fv(:,2)==0;
    se = false( numedges, 1 );
    for fi=1:numfaces
        if sf(fi)
            se( volcells.faceedges{fi}, 1 ) = true;
        end
    end
    svx = false( getNumberOfVolVertexes( volcells ), 1 );
    svx( unique( volcells.edgevxs(se,:) ), 1 ) = true;
    svol = false( getNumberOfVolCells( volcells ), 1 );
    if any(fv(sf,1)==0)
        xxxx = 1;
    end
    foo = fv(sf,1);
    svol( foo(foo~=0), 1 ) = true;
end