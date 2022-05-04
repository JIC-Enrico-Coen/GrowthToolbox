function [cn,vn] = biocellNormals( m, cis )
%cn = biocellNormals( m, cis )
%   Calculate normal vectors to the cells of M listed in CIS (by default,
%   all of them).
%[cn,vn] = biocellNormals( m, cis )
%   Calculate cell normals as above, and also vertex normals.

    if ~hasNonemptySecondLayer(m)
        cn = zeros(0,3);
        vn = zeros(0,3);
    else
        if nargin < 2
            cis = 1:getNumberOfCells(m);
        elseif islogical(cis)
            cis = find(cis);
        end
        [cn,vn] = polyNormals( m.secondlayer.cell3dcoords, { m.secondlayer.cells(cis).vxs } );
%         nc = length(cis);
%         cn = zeros(nc,3);
%         for cii = 1:nc
%             ci = cis(cii);
%             cvxs = m.secondlayer.cells(ci).vxs;
%             [c,p,flatness,planarity,v,d] = bestFitPlane( m.secondlayer.cell3dcoords(cvxs,:), 'area' );
%             cn(cii,:) = p;
%         end
%         
%         if nargout >= 2
%             vn = zeros( getNumberOfCellvertexes(m), 3 );
%             nvn = zeros( getNumberOfCellvertexes(m), 1 );
%             for cii = 1:nc
%                 ci = cis(cii);
%                 cvxs = m.secondlayer.cells(ci).vxs;
%                 vn( cvxs, : ) = vn( cvxs, : ) + cn(cii,:);
%                 nvn( cvxs ) = nvn( cvxs )+1;
%             end
%             vn = vn ./ nvn;
%             vn = vn ./ sqrt(sum(vn.^2,2));
%             vn(isnan(vn)) = 0;
%         end
    end
end
