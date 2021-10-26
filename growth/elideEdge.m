function [m,elided,newedgeindex] = elideEdge( m, ei, threshold )
%[m,elided,newedgeindex] = elideEdge( m, ei, threshold )
%   Shrink the edge ei to a point, and the cells on either side to single
%   edges.  The transformation will not be done if it would make the mesh
%   invalid, or if it would reduce the quality of any cell below the
%   threshold.  elided is true if the transformation was done.
%   The mesh is not validated afterwards: this should be done after a batch
%   of calls to elideEdge.
%   newedgeindex is the mapping from old edge indexes to new.
%
%   For foliate meshes only.

    if nargin < 3
        threshold = 0.1;
    end
    
    elided = false;
    newedgeindex = [];

    numnodes = size(m.nodes,1);
    numedges = size(m.edgeends,1);
    numcells = size(m.tricellvxs,1);

    c1 = m.edgecells(ei,1);
    c2 = m.edgecells(ei,2);
    isborder = c2==0;

    c1ei = find( m.celledges(c1,:)==ei, 1 );
    [c1eia,c1eib] = othersOf3( c1ei );
    ei1a = m.celledges(c1,c1eia);
    ei1b = m.celledges(c1,c1eib);
    opp1 = m.tricellvxs(c1,c1ei);
    opp1nce = m.nodecelledges{opp1};
    numopp1edges = size( opp1nce, 2 );
    if (numopp1edges == 3) && (opp1nce(2,3) ~= 0)
        % Invalid elision -- would create two triangles with the same edges.
      % fprintf( 1, '%s: cannot elide edge %d (merging edges %d and %d creates two triangles with two edges in common).\n', ...
      %     mfilename(), ei, ei1a, ei1b );
        return;
    end
    if numopp1edges < 3
        % Invalid elision -- deletes a vertex.
      % fprintf( 1, '%s: cannot elide edge %d (deletes vertex %d).\n', mfilename(), ei, opp1 );
        return;
    end
    edgemap = true(1,numedges);
    edgemap(ei) = false;
    edgemap(ei1b) = false;
    if isborder
        opp2 = 0;
    else
        c2ei = find( m.celledges(c2,:)==ei, 1 );
        [c2eia,c2eib] = othersOf3( c2ei );
        ei2a = m.celledges(c2,c2eia);
        ei2b = m.celledges(c2,c2eib);
        opp2 = m.tricellvxs(c2,c2ei);
        opp2nce = m.nodecelledges{opp2};
        numopp2edges = size( opp2nce, 2 );
        if (numopp2edges == 3) && (opp2nce(2,3) ~= 0)
            % Invalid elision -- would create two triangles with the same edges.
          % fprintf( 1, '%s: cannot elide edge %d (merging edges %d and %d creates two triangles with two edges in common).\n', ...
          %     mfilename(), ei, ei2a, ei2b );
            return;
        end
        if numopp2edges < 3
            % Invalid elision -- deletes a vertex.
          % fprintf( 1, '%s: cannot elide edge %d (deletes vertex %d).\n', mfilename(), ei, opp2 );
            return;
        end
        edgemap(ei2b) = false;
    end
    
    end1a = m.tricellvxs(c1,c1eia);
    endp1a = [end1a*2-1,end1a*2];
    end1b = m.tricellvxs(c1,c1eib);
    endp1b = [end1b*2-1,end1b*2];
    nce1 = m.nodecelledges{end1a};
    nce2 = m.nodecelledges{end1b};
    if (~isborder) && (any(nce1(2,:)==0) && any(nce2(2,:)==0))
        % Invalid elision -- would create two parts of the mesh joined
        % by a point.
      % fprintf( 1, '%s: cannot elide edge %d (creates single-point join).\n', mfilename(), ei );
        return;
    end
    end1anbs = neighbourVxs(m,end1a);
    end1bnbs = neighbourVxs(m,end1b);
    sharedvxs = setdiff( intersect(end1anbs,end1bnbs), [opp1,opp2] );
    if ~isempty( sharedvxs )
        % Invalid elision -- would create two edges with the same ends.
      % fprintf( 1, '%s: cannot elide edge %d (creates two edges from vertex %d to joined vertex [%d %d]).\n', ...
      %     mfilename(), ei, sharedvxs(1), end1a, end1b );
        return;
    end
    
    % Update nodecelledges{opp1} by deleting c1 and ei1a.  Similarly for c2.
    nceo1 = m.nodecelledges{opp1};
    nceo1i = find( nceo1(2,:)==c1, 1 );
    opp1nce = nceo1( :, [(1:(nceo1i-1)), ((nceo1i+1):size(nceo1,2))] );
    if ~isborder
        nceo2 = m.nodecelledges{opp2};
        nceo2i = find( nceo2(2,:)==c2, 1 );
        opp2nce = nceo2( :, [(1:(nceo2i-1)), ((nceo2i+1):size(nceo2,2))] );
    end
    
    % Merge nodecelledges{end1a} and nodecelledges{end1b}.
    if isborder
        % nodecelledges{end1a} should begin with ei and c1.
        % nodecelledges{end2a} should end with ei1a, c1, ei, 0.
        end1nce = ...
            [ nce2(:,1:(size(nce2,2)-2)), ...
              [nce2(1,size(nce2,2)-1); nce1(2,2)], ...
              nce1(:,3:size(nce1,2)) ];
          % [ [nce2(1,:), nce1(1,size(nce1,2)]; ...
          %   [nce2(2,1:size(nce2,2)-1), nce1(2,:) ] ];
        if size(nce2,2) <= 2
            c1a = 0;
        else
            c1a = nce2(2,size(nce2,2)-2);
        end
        c1b = nce1(2,2);
        if (c1a==c1b)
          % fprintf( 1, '%s: cannot elide edge %d, since cells %d and %d would have the same vertexes.\n', ...
          %     mfilename(), ei, c1a, c1b );
            return;
        end
    else
        % nodecelledges{end1a} should contain the sequence
        % ei2a c2 ei c1 ei1b.  
        % nodecelledges{end2a} should contain the sequence
        % ei1a c1 ei c2 ei2b. 
        % The respective subsequences c2 ei c1 ei1b and c1 ei c2 ei2b
        % should be deleted and the two sequences merged:
        % .... e1a .... e2a ....
        nce1a = find( nce1(1,:)==ei2a, 1 );
        nce1edges = allbut( nce1(1,:), nce1a+1, nce1a+2 );
        nce1cells = allbut( nce1(2,:), nce1a, nce1a+1 );
        c1b = nce1cells(1);
        c2a = nce1cells(length(nce1cells));
        nce2a = find( nce2(1,:)==ei1a, 1 );
        nce2edges = allbut( nce2(1,:), nce2a+1, nce2a+2 );
        nce2cells = allbut( nce2(2,:), nce2a, nce2a+1 );
        c2b = nce2cells(1);
        c1a = nce2cells(length(nce2cells));
        if (c2a==0) && (c2b==0)
          % fprintf( 1, '%s: cannot elide edge %d, since cell %d has no other neighbours.\n', ...
          %     mfilename(), ei, c2 );
            return;
        end
        if c1a==c1b
          % fprintf( 1, '%s: cannot elide edge %d, since cells %d and %d would have the same vertexes.\n', ...
          %     mfilename(), ei, c1a, c1b );
            return;
        end
        if c2a==c2b
          % fprintf( 1, '%s: cannot elide edge %d, since cells %d and %d would have the same vertexes.\n', ...
          %     mfilename(), ei, c2a, c2b );
            return;
        end
        end1nce = [ [ nce2edges(length(nce2edges)), nce1edges, nce2edges(1:(length(nce2edges)-1)) ]; ...
                    [ nce1cells, nce2cells ] ];
        z = find( end1nce(2,:)==0, 1 );
        if ~isempty(z)
            end1nce = end1nce(:,[ (z+1):size(end1nce,2), 1:z ]);
        end
    end
    if (c1a==0) && (c1b==0)
      % fprintf( 1, '%s: cannot elide edge %d, since cell %d has no other neighbours.\n', ...
      %     mfilename(), ei, c1 );
        return;
    end
    
    
    % Place the new node.
    if isborder
        [wts,pts, newpos] = butterflystencil( m, ei );
    elseif nce1(2,size(nce1,2))==0
        wts = [1,0];
        pts = [end1a,end1b];
        newpos = m.nodes(end1a,:);
    elseif nce2(2,size(nce2,2))==0
        wts = [0,1];
        pts = [end1a,end1b];
        newpos = m.nodes(end1b,:);
    else
        [wts,pts, newpos] = butterflystencil( m, ei );
    end
    newprismpos = [ wts*m.prismnodes(pts*2-1,:); wts*m.prismnodes(pts*2,:) ];

    % Check that none of the surrounding triangles becomes of too low
    % quality.
    oldposa = m.nodes(end1a,:);
    oldprismposa = m.prismnodes(endp1a,:);
    oldposb = m.nodes(end1b,:);
    oldprismposb = m.prismnodes(endp1b,:);
  % newpos
    deformedcells = end1nce(2,:);
    deformedcells = deformedcells(deformedcells ~= 0);
    oldquality = femCellQualities( m, deformedcells );
    m.nodes(end1a,:) = newpos;
    m.prismnodes(endp1a,:) = newprismpos;
    m.nodes(end1b,:) = newpos;
    m.prismnodes(endp1b,:) = newprismpos;
    newquality = femCellQualities( m, deformedcells );
    enworsenments = find( (newquality < threshold) & (newquality < oldquality) );
    if any(enworsenments)
        m.nodes(end1a,:) = oldposa;
        m.prismnodes(endp1a,:) = oldprismposa;
        m.nodes(end1b,:) = oldposb;
        m.prismnodes(endp1b,:) = oldprismposb;
        if false
            fprintf( 1, '%s: cannot elide edge %d: reduces quality of cells.\n', ...
                mfilename(), ei );
            for i=1:length(enworsenments)
                ewi = enworsenments(i);
                fprintf( 1, '    Cell %d: oldq %.3f newq %.3f.\n', ...
                    deformedcells(ewi), ...
                    oldquality(ewi), ...
                    newquality(ewi) );
            end
        end
        return;
    end
    averaged = strcmp( m.mgen_interpType, 'mid' ) | strcmp( m.mgen_interpType, 'average' );
    m.morphogens(end1a,averaged) = wts*m.morphogens(pts,averaged);
    m.mgen_production(end1a,averaged) = wts*m.mgen_production(pts,averaged);
    m.mgen_absorption(end1a,averaged) = wts*m.mgen_absorption(pts,averaged);
    m.morphogenclamp(end1a,averaged) = wts*m.morphogenclamp(pts,averaged);
    
    % When amalgamating vertexes, both 'min' and 'max' morphogens use the
    % maximum.
    extremed = ~averaged;
    m.morphogens(end1a,extremed) = min( m.morphogens(end1a,extremed), m.morphogens(end1b,extremed) );
    m.mgen_production(end1a,extremed) = min( m.mgen_production(end1a,extremed), m.mgen_production(end1b,extremed) );
    m.mgen_absorption(end1a,extremed) = min( m.mgen_absorption(end1a,extremed), m.mgen_absorption(end1b,extremed) );
    m.morphogenclamp(end1a,extremed) = min( m.morphogenclamp(end1a,extremed), m.morphogenclamp(end1b,extremed) );
    
    if ~isempty( m.vertexnormals )
        m.vertexnormals(end1a,:) = wts*m.vertexnormals(pts,:);
    end

    
    % Now update the mesh.
    
    nbdcells = end1nce(2,:);
    nbdcells = nbdcells(nbdcells ~= 0);
    m.unitcellnormals(nbdcells,:) = unitcellnormal( m, nbdcells );

    m.nodecelledges{end1a} = end1nce;
    m.nodecelledges{opp1} = opp1nce;
    if ~isborder
        m.nodecelledges{opp2} = opp2nce;
    end
    
    m.edgeends(ei1a,:) = [opp1,end1a];
    if ~isborder
        m.edgeends(ei2b,:) = [opp2,end1a];
    end

    m.edgecells(ei1a,:) = sort( [c1a,c1b], 'descend' );
    if ~isborder
        m.edgecells(ei2a,:) = sort( [c2a,c2b], 'descend' );
    end

    m.fixedDFmap(endp1a,:) = m.fixedDFmap(endp1a,:) | m.fixedDFmap(endp1b,:);
    if c2==0
        changedcells = [c1,nbdcells];
    else
        changedcells = [c1,c2,nbdcells];
    end

    % Now renumber everything.
    nodemap = true(1,numnodes);
    nodemap(end1b) = false;
    newnodeindex = [ 1:(end1b-1), 0, end1b:(numnodes-1) ];
    newnodeindex(end1b) = newnodeindex(end1a);

    retainededges = find(edgemap);
    newedgeindex = 1:numedges;
    newedgeindex(edgemap) = 1:length(retainededges);
    newedgeindex(ei) = 0;
    newedgeindex(ei1b) = newedgeindex(ei1a);
    if ~isborder
        newedgeindex(ei2b) = newedgeindex(ei2a);
    end

    cellmap = true(1,numcells);
    cellmap(c1) = false;
    if ~isborder
        cellmap(c2) = false;
    end
    retainedcells = find(cellmap);
    newcellindex = zeros(1,numcells);
    newcellindex(retainedcells) = 1:length(retainedcells);

    if hasNonemptySecondLayer( m )
        changedcellsmap = false(numcells,1);
        changedcellsmap(changedcells) = true;
        biovxsToFix = find( changedcellsmap(m.secondlayer.vxFEMcell) );
    end

    m = renumberMesh( m, ...
            newnodeindex, newedgeindex, newcellindex, ...
            nodemap, edgemap, cellmap );

    if hasNonemptySecondLayer( m )
        nbdcells = newcellindex(nbdcells);
        m = fixSecondLayer( m, biovxsToFix, nbdcells );
    end

    % [ok,m] = validmesh(m);
    elided = true;
end

function b = allbut( a, a1, a2 )
    a2 = mod(a2-1,length(a))+1;
    if a1 <= a2
        b = a( [ (a2+1):end, 1:(a1-1) ] );
    else
        b = a( (a2+1):(a1-1) );
    end
end

