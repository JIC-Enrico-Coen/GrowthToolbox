function s = orientMesh( s )
%s = orientMesh( s )
%   Force s to be oriented.

% For each edge, we need to record whether its orientations in each of the
% cells it belongs to are consistent.  (Always true for border edges.)

    numCells = size(s.tricellvxs,1);
    numEdges = size(s.edgeends,1);
    interioredges = s.edgecells(:,2) ~= 0;
    edgevv = [s.celledges(:) [s.tricellvxs(:,[2 3]); s.tricellvxs(:,[3 1]); s.tricellvxs(:,[1 2])] ];
    edgevv( ~interioredges(edgevv(:,1)), : ) = [];
    edgevv = sortrows(edgevv);
    edgevv = reshape( edgevv', 6, [] )';
    edgeagreement = true(numEdges,1);
    edgeagreement(interioredges) = edgevv(:,2) == edgevv(:,6);
    
    if all(edgeagreement)
        fprintf( 1, '%s: all edges correct.\n', mfilename() );
        return;
    end
    
    cellsprocessedmap = false( numCells, 1 );
    cellstobeprocessedlist = 1;
    cellstoignoremap = false( numCells, 1 );
    cellstoignoremap(1) = true;
    numCellsCorrected = 0;
    
    while ~isempty(cellstobeprocessedlist)
        ci = cellstobeprocessedlist(end);
        cei = edgeagreement( s.celledges(ci,:) );
        othercells = s.edgecells(s.celledges(ci,:),:)';
        othercells = othercells(othercells ~= ci);
        for j=1:3
            if ~cei(j)
                oci = othercells(j);
                s.tricellvxs(oci,:) = s.tricellvxs(oci,[1 3 2]);
                s.celledges(oci,:) = s.celledges(oci,[1 3 2]);
                edgeagreement(s.celledges(oci,:)) = ~edgeagreement(s.celledges(oci,:));
                numCellsCorrected = numCellsCorrected+1;
            end
        end
        cellsprocessedmap(ci) = true;
        cellstoignoremap(ci) = true;
        newcells = othercells(othercells ~= 0);
        newcells( cellstoignoremap(newcells) ) = [];
        cellstoignoremap(newcells) = true;
        cellstobeprocessedlist = [ cellstobeprocessedlist(1:end-1); newcells ];
    end
    
    fprintf( 1, '%s: %d cells flipped.\n', mfilename(), numCellsCorrected );
end

