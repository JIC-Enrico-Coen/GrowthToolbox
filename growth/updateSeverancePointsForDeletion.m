function mt = updateSeverancePointsForDeletion( mt, deletedRange )
%mt = updateSeverancePointsForDeletion( mt, deletedRange )
%   The given range of vertexes is about to be deleted from the microtubule.
%   Update all of its severance data accordingly.

    if isempty( mt.status.severance )
        % No severances to filter.
        return;
    end
    
    if deletedRange(2) < deletedRange(1)
        % No vertexes deleted.
        return;
    end
    
    severvxs = [ mt.status.severance.vertex ];
    before = severvxs < deletedRange(1)-1;
    after = severvxs > deletedRange(2)+1;
    inrange = (severvxs > 1) & (severvxs < length( mt.vxcellindex ));
    validsv = (before | after) & inrange;
    for i=1:length(after)
        if after(i)
            mt.status.severance(i).vertex = mt.status.severance(i).vertex - (deletedRange(2) - deletedRange(1) + 1);
        end
    end
    mt.status.severance = mt.status.severance( validsv );
end
