function ok = checklineagevalid( secondlayer, complainer )
%ok = checklineagevalid( secondlayer, complainer )
%   Make validity checks on the cell lineage data.
%   COMPLAINER is either @error or @warning.

    if nargin < 2
        complainer = @warning;
    end
    ok = true;
    numcells = length( secondlayer.cells );
    
    % Every cell must have a nonzero cell id.
    if isfield( secondlayer, 'cellid' )
        maxcellid = length( secondlayer.cellidtoindex );
        if length(secondlayer.cellid) ~= numcells
            complainer( 'Wrong length of cellid, found %d, expected %d.\n', length(secondlayer.cellid), numcells );
            ok = false;
        end
        if length(secondlayer.cellid) ~= length(unique(secondlayer.cellid))
            complainer( 'Some existing cells have the same id.' );
            ok = false;
        end
        numinvalidids = sum( (secondlayer.cellid <= 0) | (secondlayer.cellid > maxcellid) );
        if any(secondlayer.cellid <= 0)
            complainer( '%d invalid cellids.\n', numinvalidids );
            ok = false;
        end
        if size(secondlayer.cellidtotime,1) ~= maxcellid
            complainer( 'Wrong length of cellidtotime: found %d, expected %d.\n', size(secondlayer.cellidtotime,1), maxcellid );
            ok = false;
        end
        if ok
            if ~all(secondlayer.cellidtoindex( secondlayer.cellid ) == (1:numcells)')
                complainer( 'cellidtoindex(cellid) ~= 1:numcells.' );
                ok = false;
            end
        end
        if ok
            id_defined = find(secondlayer.cellidtoindex>0);
            if ~all( secondlayer.cellid( secondlayer.cellidtoindex(id_defined) ) == id_defined )
                complainer( 'cellid(cellidtoindex(cellidtoindex>0) ) ~= find(cellidtoindex>0).' );
                ok = false;
            end
        end
        
        % Check daughters are consistent with parents.
%         haveparent = secondlayer.cellparent > 0;
%         daughterofparent = secondlayer.celldaughters(secondlayer.cellparent(haveparent),:);
%         if ~all(all(daughterofparent == repmat( find(haveparent), 1, 2 )))
%             complainer( 'Some ' );
%             ok = false;
%         end
    end
    if ~ok
        xxxx = 1;
    end
end