function ok = checklineagevalid( secondlayer, severity )
%ok = checklineagevalid( secondlayer, severity )
%   Make validity checks on the cell lineage data.

    if nargin < 2
        severity = 0;
    end
    ok = true;
    numcells = length( secondlayer.cells );
    
    % Every cell must have a nonzero cell id.
    if isfield( secondlayer, 'cellid' )
        maxcellid = length( secondlayer.cellidtoindex );
        if length(secondlayer.cellid) ~= numcells
            complain2( severity, 'Wrong length of cellid, found %d, expected %d.', length(secondlayer.cellid), numcells );
            ok = false;
        end
        if length(secondlayer.cellid) ~= length(unique(secondlayer.cellid))
            complain2( severity, 'Some existing cells have the same id.' );
            ok = false;
        end
        numinvalidids = sum( (secondlayer.cellid <= 0) | (secondlayer.cellid > maxcellid) );
        if any(secondlayer.cellid <= 0)
            complain2( severity, '%d invalid cellids.', numinvalidids );
            ok = false;
        end
        if size(secondlayer.cellidtotime,1) ~= maxcellid
            complain2( severity, 'Wrong length of cellidtotime: found %d, expected %d.', size(secondlayer.cellidtotime,1), maxcellid );
            ok = false;
        end
        if ok
            if ~all(secondlayer.cellidtoindex( secondlayer.cellid ) == (1:numcells)')
                complain2( severity, 'cellidtoindex(cellid) ~= 1:numcells at %d places.', sum( secondlayer.cellidtoindex( secondlayer.cellid ) ~= (1:numcells)' ) );
                ok = false;
            end
        end
        if ok
            id_defined = find(secondlayer.cellidtoindex>0);
            if ~all( secondlayer.cellid( secondlayer.cellidtoindex(id_defined) ) == id_defined )
                complain2( severity, 'cellid(cellidtoindex(cellidtoindex>0) ) ~= find(cellidtoindex>0).' );
                ok = false;
            end
        end
        
        % Check daughters are consistent with parents.
%         haveparent = secondlayer.cellparent > 0;
%         daughterofparent = secondlayer.celldaughters(secondlayer.cellparent(haveparent),:);
%         if ~all(all(daughterofparent == repmat( find(haveparent), 1, 2 )))
%             complain2( severity, 'Some ' );
%             ok = false;
%         end
    end
    if ~ok
        xxxx = 1;
    end
end