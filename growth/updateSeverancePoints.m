function mt = updateSeverancePoints( mt, changePoint, sizeChange )
%
%   This is to be called whenever a microtubule changes its vertex set.
%
%   mt is the microtubule, in which the vertex set has not yet been
%   changed, but will be after this procedure is called.
%
%   changePoint is the index of the vertex where the change happens.
%
%   sizeChange, if positive, is the number of vertexes to be added
%   immediately after changePoint. If negative, it is the number of
%   vertexes to be deleted starting from and including changePoint.

    if isempty( mt.status.severance )
        return;
    end
    
    if sizeChange==0
        return;
    end
    
    deleting = sizeChange < 0;
    if deleting
        lastToDelete = changePoint-sizeChange-1;
    end
    problem = false( 1, length( mt.status.severance ) );
    validsv = true( 1, length( mt.status.severance ) );
    for i=1:length( mt.status.severance )
        seververtex = mt.status.severance(i).vertex;
        if changePoint > seververtex
            % The modification is nearer to the head than seververtex.
            continue;
        end
        if deleting && (changePoint <= seververtex) && (lastToDelete >= seververtex)
            % The seververtex is being deleted.
            validsv(i) = false;
            continue;
        end
        newvi = seververtex + sizeChange;
        oldseverance = mt.status.severance(i);
        mt.status.severance(i).vertex = newvi;
        mt.status.severance(i).FE = mt.segcellindex(newvi);
        mt.status.severance(i).bc = mt.barycoords(newvi,:);
        mt.status.severance(i).globalpos = mt.globalcoords(newvi,:);
    end

    sv = [mt.status.severance.vertex];
    validsv = (validsv & (sv >= 1) & (sv < length( mt.vxcellindex ))) | problem;
    mt.status.severance = mt.status.severance( validsv );
end
