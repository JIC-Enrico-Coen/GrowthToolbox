function mt = updateSeverancePointsForInsertion( mt, vertexBeforeInsertion )
%mt = updateSeverancePointsForInsertion( mt, vertexBeforeInsertion )
%   A vertex is to be inserted into the microtubule just after the given vertex.
%   Update all of its severance data accordingly.

    if isempty( mt.status.severance )
        % No severances to update.
        return;
    end
    
    if (vertexBeforeInsertion < 1) || (vertexBeforeInsertion > length( mt.vxcellindex ))
        % Invalid vertex.
        return;
    end
    
    for i=1:length( mt.status.severance )
        seververtex = mt.status.severance(i).vertex;
        if seververtex > vertexBeforeInsertion
            mt.status.severance(i).vertex = mt.status.severance(i).vertex+1;
        end
    end
    
    severvxs = [mt.status.severance.vertex];
    inrange = (severvxs > 1) & (severvxs <= length( mt.vxcellindex ));
    mt.status.severance = mt.status.severance( inrange );
end
