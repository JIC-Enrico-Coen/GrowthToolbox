function m = dissectmesh( m, seamedges, deleteNum )
%m = dissectmesh( m, seamedges, deleteNum )
%   Cut m along all its seam edges. Delete fragments containing no more
%   than deleteNum elements.

    % Each seam edge must be duplicated.
    % Each seam vertex lying on n seam edges must have n copies (including
    % itself).
    
    full3d = usesNewFEs( m );
    if full3d
        % This functionality is not supported for full 3d meshes.
        return;
    end
    
    numnodes = size(m.nodes,1);
    numedges = size(m.edgeends,1);
    useMseams = (nargin < 2) || (seamedges == 0);
    if useMseams
        seams = m.seams;
        seamedges = find(seams);
    else
        seams = false( numedges, 1 );
        seams(seamedges) = true;
    end
    m.seams(seamedges) = false;

    % Seam edges that are on the border of the mesh are not seams.
    nonseams = m.edgecells(seamedges,2)==0;
    if ~isempty(nonseams)
        seams(seamedges(nonseams)) = false;
        seamedges(nonseams) = [];
    end
    
    % No seams?  Do nothing.
    if isempty(seamedges)
        return;
    end
    numseamedges = length(seamedges);
    
  % m = deleteCellsOnBadEdges( m, seamedges );  % Does not work.

    % Update second layer.  Some cells may straddle seam edges.  Delete them.
    if hasNonemptySecondLayer( m )
        m.secondlayer = deleteSecondLayerCells( m.secondlayer, findBridgingCells( m, seamedges ), m.globalDynamicProps.currenttime );
    end
    
    seamvxcount = zeros( size(m.nodes,1), 1 );
    for i=1:numseamedges
        vxs = m.edgeends(seamedges(i),:);
        seamvxcount( vxs ) = seamvxcount( vxs ) + 1;
    end
    seamvxs = find( seamvxcount > 0 );
    clear seamvxcount;
    numseamvxs = length( seamvxs );
    oldedgecells = m.edgecells(seamedges,:);
    
    newEdgeIndexes = (numedges+1):(numedges+numseamedges);
    m.edgeends( newEdgeIndexes, : ) = m.edgeends( seamedges, : );
    m.edgecells( newEdgeIndexes, : ) = m.edgecells( seamedges, : );
    affectedCells = unique( m.edgecells( seamedges, : ) );
    
    % For each seam edge, update celledges and edgecells.
    for sei = 1:numseamedges
        ei = seamedges(sei);
        newei = numedges + sei;
        c1 = m.edgecells(ei,1);
        c2 = m.edgecells(ei,2);
        m.edgecells(ei,:) = [c1,0];
        m.edgecells(newei,:) = [c2,0];
        m.celledges( c2, m.celledges( c2, : )==ei ) = newei;
    end

    % For each node, use nce to update tricellvxs.
    globnewvxi = numnodes;
    for svi = 1:numseamvxs
        vi = seamvxs(svi);
        nce = m.nodecelledges{vi};
        numnodeedges = size(nce,2);
        nceseams = seams(nce(1,:))';
        nceseamedges = nce(1,nceseams);
        nodedegree = size(nce,2);
        seamdegree = length(nceseamedges);
        isborder = nce(2,numnodeedges)==0;
        if isborder
            nceseams(numnodeedges) = true;
            seamdegree = seamdegree+1;
        end
        if seamdegree > 1
            newvxi = zeros(nodedegree,1);
            curdesc = 0;
            for ncei = 1:nodedegree
                if nceseams(ncei)
                    curdesc = curdesc+1;
                    if curdesc==seamdegree
                        curdesc = 0;
                    end
                end
                newvxi(ncei) = curdesc;
            end
            for ncei = 1:nodedegree
                ci = nce(2,ncei);
                if ci ~= 0
                    nvxi = newvxi(ncei);
                    if nvxi ~= 0
                        newnodeindex = globnewvxi + nvxi;
                        m.tricellvxs( ci, m.tricellvxs(ci,:)==vi ) = newnodeindex;
                     %  m.nodes(newnodeindex,:) = m.nodes(vi,:);
                     %  m.prismnodes([newnodeindex+newnodeindex-1,newnodeindex+newnodeindex],:) = ...
                     %      m.prismnodes([vi+vi-1,vi+vi],:);
                    end
                end
            end
            newglobnewvxi = globnewvxi + seamdegree - 1;
            m = duplicatenode( m, vi, (globnewvxi+1):newglobnewvxi );
            globnewvxi = newglobnewvxi;
        end
    end
    
    for ci=1:size(m.tricellvxs,1)
        m.edgeends( m.celledges(ci,:), : ) = ...
            reshape( m.tricellvxs(ci,[2 3 1 3 1 2]), 3, 2 );
    end
    
    % Then reconstruct nce and edgeends.
    for sei = 1:numseamedges
        ei = seamedges(sei);
        
        c1 = oldedgecells(sei,1);
        c1ei = find( m.celledges( c1, : )==ei );
        m.edgeends( ei, : ) = m.tricellvxs( c1, othersOf3( c1ei ) );
        
        c2 = oldedgecells(sei,2);
        newei = numedges + sei;
        c2ei = find( m.celledges( c2, : )==newei );
        m.edgeends( numedges + sei, : ) = m.tricellvxs( c2, othersOf3( c2ei ) );
    end
    m = makeVertexConnections( m );
    
    % Update edge properties: currentbendangle, initialbendangle.  These
    % should be zero for seam edges and their duplicates.
    m.currentbendangle(seams) = 0;
    m.currentbendangle(newEdgeIndexes) = 0;
    m.initialbendangle(seams) = 0;
    m.initialbendangle(newEdgeIndexes) = 0;
    
    % The new edges are not seams.
    m.seams(newEdgeIndexes) = false;
    
    % Delete all small fragments.
    m = deleteSmallFragments( m, deleteNum );
    
    [ok,m] = validmesh(m);
    if ~ok
        warning( [ mfilename(), ' yielded an invalid mesh.' ] );
    end
    
end

    
