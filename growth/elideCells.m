function [m,elided] = elideCells( m, ei, threshold, force )
%m = elideCells( m, ei, threshold, force )
%   Shrink the cells on either side of edge ei down to ei, splitting ei in
%   the middle.
%   Threshold is a value of triangle quality such that if any triangle has
%   its quality decreased to a value below the threshold, the
%   transformation will not be done.  The default is 0.1.
%   If force is true, the quality criterion will be ignored and the
%   transformation will always be done unless it would make the mesh
%   invalid.  The default is false.

    if (nargin < 3) || isempty(threshold)
        threshold = 0.1;
    end
    if nargin < 4
        force = false;
    end
    elided = false;

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
    popp1 = prismIndexes( opp1 );
    end1a = m.tricellvxs(c1,c1eia);
    end1b = m.tricellvxs(c1,c1eib);
    nce1 = m.nodecelledges{end1a};
    nce2 = m.nodecelledges{end1b};
    oppnce1 = m.nodecelledges{opp1};
    opp1border = any( oppnce1(2,:)==0 );
    if ~isborder
        c2ei = find( m.celledges(c2,:)==ei, 1 );
        [c2eia,c2eib] = othersOf3( c2ei );
        ei2a = m.celledges(c2,c2eia);
        ei2b = m.celledges(c2,c2eib);
        opp2 = m.tricellvxs(c2,c2ei);
        popp2 = prismIndexes( opp2 );
        oppnce2 = m.nodecelledges{opp2};
        opp2border = any( oppnce2(2,:)==0 );
        if opp1border && opp2border
            % Invalid elision -- would merge two different parts of the
            % border.
            fprintf( 1, 'elideCells: cannot elide edge %d, as vertexes %d and %|d are both on the border.\n', ...
                ei, opp1, opp2 );
            return;
        end
    end
    
    edgemap = true(1,numedges);
    edgemap(ei) = false;
    if ~isborder
        edgemap(ei2a) = false;
        edgemap(ei2b) = false;
    end
    retainededges = find(edgemap);
    renumberedges = 1:numedges;
    renumberedges(retainededges) = 1:length(retainededges);
    renumberedges(ei) = 0;
    if ~isborder
    	renumberedges(ei2a) = renumberedges(ei1b);
    	renumberedges(ei2b) = renumberedges(ei1a);
    end
    
    if isborder
        renumbernodes = [];
        nodemap = [];
    else
        nodemap = true( 1, size(m.nodes,1) );
        nodemap(opp2) = 0;
        retainednodes = [ 1:(opp2-1), (opp2+1):numnodes ];
        renumbernodes = [ 1:(opp2-1), 0, opp2:(numnodes-1) ];
        renumbernodes(opp2) = renumbernodes(opp1);
        retainedprismnodes = retainednodes*2;
        retainedprismnodes = reshape( [ retainedprismnodes-1; retainedprismnodes ], 1, [] );
    end

    cellmap = true(1,numcells);
    cellmap(c1) = false;
    if ~isborder
        cellmap(c2) = false;
    end
    retainedcells = find(cellmap);
    renumbercells = 1:numcells;
    renumbercells(retainedcells) = 1:length(retainedcells);
    renumbercells(c1) = 0;
    if ~isborder
        renumbercells(c2) = 0;
    end
    
    % Update nodecelledges{end1a} by deleting ei2a, c2, e1, and c1.
    % Update nodecelledges{end2a} by deleting c1, e1, c2, and ei2b.
    nce1i = find( nce1(2,:)==c1, 1 );
    nce2i = find( nce2(2,:)==c1, 1 );
    nce1 = nce1( :, [((nce1i+1):size(nce1,2)), (1:(nce1i-1))] );
    if c2==0
        nce2(2,nce2i) = 0;
        nce2i = nce2i+1;
        if nce2i > size(nce2,2)
            nce2i = 1;
        end
        nce2(:,nce2i) = [];
    else
        nce1(:,end) = [];
        nce2(:,nce2i) = [];
        if nce2i > size(nce2,2)
            nce2i = 1;
        end
        nce2(:,nce2i) = [];
        if nce2i > size(nce2,2)
            nce2i = 1;
        end
        nce2(1,nce2i) = ei1a;
    end
    
    % Merge nodecelledges{opp1} and nodecelledges{opp2}.
    if isborder
        % nodecelledges{opp1} replaces c1 by 0.
        oppnce1(2,oppnce1(2,:)==c1) = 0;
    else
        % Delete ei1b and c1 from oppnce1, and ei2b and c2 from oppnce2,
        % and merge the results.
        opp1c1i = find(oppnce1(2,:)==c1);
        opp2c2i = find(oppnce2(2,:)==c2);
        opp2c2ia = mod(opp2c2i,size(oppnce2,2)) + 1;
        oppnce1 = [ oppnce1(:,(opp1c1i+1):size(oppnce1,2)), ...
                       oppnce1(:,1:(opp1c1i-1)), ...
                       [ ei1b; oppnce2(2,opp2c2ia) ], ...
                       oppnce2(:,(opp2c2ia+1):size(oppnce2,2)), ...
                       oppnce2(:,1:(opp2c2i-1)) ];
      % m.nodecelledges{opp1} = newoppnce1;
    end    
    
    % Place the new node.
    if opp1border
        wts = 1;
        pts = opp1;
        newpos = m.nodes(pts,:);
    elseif (~isborder) && opp2border
        wts = 1;
        pts = opp2;
        newpos = m.nodes(pts,:);
    else
        [wts,pts,newpos] = butterflystencil( m, ei );
    end
    newprismpos = [ wts*m.prismnodes(pts*2-1,:); wts*m.prismnodes(pts*2,:) ];
    
    % Check that none of the surrounding triangles becomes of too low
    % quality, unless force is true.
    if ~force
        % Save old positions.
        oldpos1 = m.nodes(opp1,:);
        oldprismpos1 = m.prismnodes(popp1,:);
        if ~isborder
            oldpos2 = m.nodes(opp2,:);
            oldprismpos2 = m.prismnodes(popp2,:);
        end
        deformedcells = oppnce1(2,:);
        deformedcells = deformedcells(deformedcells ~= 0);
        oldquality = femCellQualities( m, deformedcells );
    end
    m.nodes(opp1,:) = newpos;
    m.prismnodes(popp1,:) = newprismpos;
    if ~isborder
        m.nodes(opp2,:) = newpos;
        m.prismnodes(popp2,:) = newprismpos;
    end
    if ~force
        newquality = femCellQualities( m, deformedcells );
        enworsenments = find( (newquality < threshold) & (newquality < oldquality) );
        if any(enworsenments)
            m.nodes(opp1,:) = oldpos1;
            m.prismnodes(popp1,:) = oldprismpos1;
            if ~isborder
                m.nodes(opp2,:) = oldpos2;
                m.prismnodes(popp2,:) = oldprismpos2;
            end
            fprintf( 1, '%s: cannot elide cells of edge %d: reduces quality of cells.\n', ...
                mfilename(), ei );
            if false
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
    end

    % Now update the mesh.
    
    if ~isempty(m.displacements)
        m.displacements(popp1,:) = [ wts*m.displacements(pts*2-1,:); wts*m.displacements(pts*2,:) ];
    end
    m.nodecelledges{end1a} = nce1;
    m.nodecelledges{end1b} = nce2;
    m.nodecelledges{opp1} = oppnce1;
    c1a = othercell( m, c1, ei1a );
    c1b = othercell( m, c1, ei1b );
    if isborder
        c2a = 0;
        c2b = 0;
    else
        c2a = othercell( m, c2, ei2a );
        c2b = othercell( m, c2, ei2b );
    end
    m.edgecells(ei1a,:) = sort( [c1a,c2b], 'descend' );
    m.edgecells(ei1b,:) = sort( [c1b,c2a], 'descend' );


    % Now renumber everything.
    m = renumberMesh( m, renumbernodes, renumberedges, renumbercells, ...
                         nodemap, edgemap, cellmap );

    % Check for anything else that needs updated: cell normals, gradients.
    nbdcells = oppnce1(2,:);
    nbdcells = renumbercells(nbdcells(nbdcells~=0));
    m.unitcellnormals(nbdcells,:) = unitcellnormal( m, nbdcells );
    m = calcPolGrad( m, nbdcells );

    if ~validmesh(m);
        error('Oops!');
    end
    
    % What about the bio layer?
    
    elided = true;
end

