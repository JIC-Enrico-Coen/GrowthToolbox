function [m,splitdata] = splitalledges( m, es, force )
%m = splitalledges( m, es, force )
%   Split all the edges in the list es.  If force is true, all the
%   specified edges are split, otherwise an edge will not be split if doing
%   so would make either a finite element or an angle too small.

% splitalledges_prevalid = validmesh(m)

    splitdata = [];

    if isempty(es), return; end
    
    if isVolumetricMesh( m )
        if isT4mesh( m )
            [m,splitdata] = splitT4Edges3D( m, es );
        else
            % Not implemented.
            fprintf( 1, '** Splitting edges of volumetric meshes is supported only for tetrahedral meshes.\n' );
        end
        return;
    end
    
    if nargin < 3
        force = false;
    end
    
    oldnumcells = getNumberOfFEs( m );
    
    if ~force
        % Don't split an edge if it would make either a finite element or an angle too
        % small.
        nbcells = m.edgecells(es,:);
        okedge = true(size(es));
        maxcellarea = max(m.cellareas);
        for i=1:length(es)
            ei = es(i);
            ci1 = nbcells(i,1);
            ci2 = nbcells(i,2);
            if m.cellareas(ci1) < m.globalProps.mincellrelarea * maxcellarea
                okedge(i) = false;
                continue;
            end
            if (ci2 > 0) && (m.cellareas(ci1) < m.globalProps.mincellrelarea * maxcellarea)
                okedge(i) = false;
                continue;
            end
            cei = find(m.celledges(ci1,:)==ei);
            a = feAngle( m, ci1, cei );
            if a < m.globalProps.mincellangle*2
                okedge(i) = false;
                continue;
            end
            if ci2 > 0
                cei = find(m.celledges(ci2,:)==ei);
                a = feAngle( m, ci2, cei );
                if a < m.globalProps.mincellangle*2
                    okedge(i) = false;
                end
            end
        end
        es = es(okedge);
        numexcluded = sum(~okedge);
        if numexcluded > 0
            fprintf( 1, '%s: %d edges excluded, %d remain.\n', ...
                mfilename(), numexcluded, length(es) );
        end
    end
    
    if ~isempty( m.globalProps.splitmorphogen )
        splittableEdges = eligibleEdges( m );
        es = intersect( es, find(splittableEdges) );
    end
    
    
    if isempty(es)
        return;
    end

    weights = [ 1 0 0
                0 1 0
                0 0 1
                0 0.5 0.5
                0.5 0 0.5
                0.5 0.5 0 ];

    numnodes = size( m.nodes, 1 );
    numedges = size( m.edgeends, 1 );
    numcells = size( m.tricellvxs, 1 );
    numsplits = length(es);
    newVxIndexes = (numnodes+1):(numnodes+numsplits);
    
    ends = m.edgeends(es,:);
    ends1 = m.edgeends(es,1);
    ends2 = m.edgeends(es,2);

    splitdata = [ends1, newVxIndexes', ends2];

    splits(es) = 1:numsplits;
    
    affectedcells = unique(m.edgecells(es,:));
    if affectedcells(1)==0
        affectedcells = affectedcells(2:end);
    end
    bentedges = unique(m.celledges(affectedcells,:));
    % Every edge in bentedges will have its bending changed by the
    % splitting.  These edges will get their initialbendangle set to
    % their currentbendangle.

% 1. Place the new nodes according to the butterfly algorithm.
fprintf( 1, '%s 1: place %d new nodes.\n', mfilename(), numsplits );
    newnodepts = zeros( numsplits, 3 );
    newprismnodeslower = zeros( numsplits, 3 );
    newprismnodesupper = zeros( numsplits, 3 );
    for i=1:numsplits
        newpoint = butterfly( m, es(i) );
        delta1 = m.prismnodes( ends1(i)*2, : ) - m.prismnodes( ends1(i)*2-1, : );
        delta2 = m.prismnodes( ends2(i)*2, : ) - m.prismnodes( ends2(i)*2-1, : );
        delta = (delta1+delta2)/4;
        newnodepts(i,:) = newpoint;
        newprismnodeslower(i,:) = newpoint - delta;
        newprismnodesupper(i,:) = newpoint + delta;
    end
    
    m.nodes = [ m.nodes; newnodepts ];
    m.prismnodes = [ m.prismnodes; ...
        reshape( [ newprismnodeslower'; newprismnodesupper' ], 3, [] )' ];

% 2. Modify the edgeends array to add all the new edges that are halves of
% old edges.
fprintf( 1, '%s 2: modify edgeends.\n', mfilename() );

    m.edgeends = [m.edgeends; zeros( numsplits, 2 ) ];
    for i=1:numsplits
        ee = m.edgeends( es(i), : );
        ni = numnodes+i;
        m.edgeends( es(i), : ) = [ ee(1), ni ];
        m.edgeends( numedges+i, : ) = [ ee(2), ni ];
    end
    % For each i, the two halves of es(i) are edges es(i) and numedges+i.

    % Map old edges to their new halves.
    edgemapping = zeros(numedges+numsplits,1);
    edgemapping( es ) = (numedges+1):(numedges+numsplits);
    
% 3. Build the new cells.

fprintf( 1, '%s 3: build new cells.\n', mfilename() );
    splitedgemap = false( numedges, 1 );
    splitedgemap(es) = true;
    celledgemap = splitedgemap( m.celledges );
    if size(m.celledges,1)==1
        celledgemap = celledgemap';
    end
    cellsplits = zeros(numcells,3);
    cellsplits(celledgemap) = splits( m.celledges(celledgemap) );
    numadditionalcells = sum(celledgemap(:));
    newnumcells = oldnumcells + numadditionalcells;
    oldcells = zeros( numadditionalcells, 1 );
    newcellsmade = 0;
    
    newcellvxs = zeros( numadditionalcells, 3 );
    numpol = 1 + m.globalProps.twosidedpolarisation;
    newpolfreeze = zeros( numadditionalcells, 3, numpol );
    newpolfreezebc = zeros( numadditionalcells, 3, numpol );
    newpolfrozen = false( numadditionalcells, numpol );
    if size(m.polsetfrozen,1) > 1
        newpolsetfrozen = false( numadditionalcells, size(m.polsetfrozen,2) );
    end
    newgaPerFE = zeros( numadditionalcells, size(m.growthangleperFE,2) );
    curnewcell = 0;
    curnewedge = numedges+numsplits;

    splitinfo = zeros( numcells, 6 );
    for ci=1:numcells
        % Set up ci1, ci2, ci3 to refer to the vertexes and edges in a
        % canonical order.
        edgemap = celledgemap(ci,:);
        edgecode = edgemap(1)*4 + edgemap(2)*2 + edgemap(3);
        switch edgecode
            case { 0, 4, 6, 7 }  % 0 0 0, 1 0 0, 1 1 0, 1 1 1
                ci1 = 1;
                ci2 = 2;
                ci3 = 3;
            case { 2, 3 } % 0 1 0, 0 1 1
                ci1 = 2;
                ci2 = 3;
                ci3 = 1;
            case { 1, 5 } % 0 0 1, 1 0 1
                ci1 = 3;
                ci2 = 1;
                ci3 = 2;
        end
        
        % Now perform the splitting.
        v1 = m.tricellvxs(ci,ci1);
        v2 = m.tricellvxs(ci,ci2);
        v3 = m.tricellvxs(ci,ci3);
        oldpolfreeze = m.polfreeze( ci, [ci1,ci2,ci3], : );
        polfreezesplits = (oldpolfreeze(:,[2,3,1],:) + oldpolfreeze(:,[3,1,2],:))/2;
        extpolfreeze = [ oldpolfreeze, polfreezesplits ];
        oldpolfreezebc = m.polfreezebc( ci, [ci1,ci2,ci3], : );
        polfreezebcsplits = (oldpolfreezebc(:,[2,3,1],:) + oldpolfreezebc(:,[3,1,2],:))/2;
        extpolfreezebc = [ oldpolfreezebc, polfreezebcsplits ];
      % fprintf( 1, 'splitalledges: cell %d, edgecode %d\n', ci, edgecode );
        epfbc = m.polfreezebc( ci, [ci1,ci2,ci3], : );
        switch edgecode
            case 0 % 0 0 0
                % No split.
            case { 4, 2, 1 } % 1 0 0, 0 1 0, 0 0 1
                v4 = cellsplits(ci,ci1) + numnodes;
                [oe1,ne1] = findsplit( ci, ci1 );
                oe2 = m.celledges( ci, ci2 );
                oe3 = m.celledges( ci, ci3 );
                ne2 = curnewedge+1;  % New edge dividing cell in two.
                curnewedge = ne2;
                nc1 = curnewcell+1;
                curnewcell = nc1;
                m.tricellvxs( ci, : ) = [ v1 v2 v4 ];
                m.polfreeze( ci, :, : ) = extpolfreeze( :, [1 2 4], : );
                m.polfreezebc( ci, :, : ) = [ epfbc(:,1,:), epfbc(:,2,:)-epfbc(:,3,:), 2*epfbc(:,3,:) ];
                m.celledges( ci, : ) = [ oe1, ne2, oe3 ];
                newcellvxs(nc1,:) = [ v1 v4 v3 ];
                newpolfreeze( nc1, :, : ) = extpolfreeze( :, [1 4 3], : );
                newpolfreezebc( nc1, :, : ) = [ epfbc(:,1,:), 2*epfbc(:,2,:), epfbc(:,3,:)-epfbc(:,2,:) ];
                newpolfrozen( nc1, : ) = m.polfrozen( ci, : );
                if size(m.polsetfrozen,1) > 1
                    newpolsetfrozen( nc1,: ) = m.polsetfrozen( ci, : );
                end
                if ~isempty( m.growthangleperFE )
                    newgaPerFE( nc1, : ) = m.growthangleperFE( ci, : );
                end
                m.celledges( numcells+nc1, : ) = [ ne1, oe2, ne2 ];
                m.edgeends( ne2, : ) = [ v1 v4 ];
                splitinfo( ci, : ) = [ numcells+nc1, 0, 0, ci1, ci2, ci3 ];
                newcellsmade = newcellsmade+1;
                oldcells(newcellsmade) = ci;
    
            case { 6, 5, 3 } % 1 1 0, 1 0 1, 0 1 1
                v4 = cellsplits(ci,ci1) + numnodes;
                v5 = cellsplits(ci,ci2) + numnodes;
                [oe1,ne1] = findsplit( ci, ci1 );
                [oe2,ne2] = findsplit( ci, ci2 );
                oe3 = m.celledges( ci, ci3 );
                ne3 = curnewedge+1;  % New edge joining v4 to v1 or v5 to v2.
                ne4 = curnewedge+2;  % New edge joining v4 and v5.
                curnewedge = ne4;
                nc1 = curnewcell+1;  % New cell sharing v1 with old cell.
                nc2 = curnewcell+2;  % New cell sharing v3 with old cell.
                curnewcell = nc2;
                m.edgeends( ne3, : ) = [ v4 v5 ];
                d41 = m.nodes(v4,:) - m.nodes(v1,:);
                d41 = dot(d41,d41);
                d52 = m.nodes(v5,:) - m.nodes(v2,:);
                d52 = dot(d52,d52);
                if d41 < d52
                    m.tricellvxs( ci, : ) = [ v1 v2 v4 ];
                    m.polfreeze( ci, :, : ) = extpolfreeze( :, [1 2 4], : );
                    % m.polfreezebc( ci, :, : ) = extpolfreezebc( :, [1 2 4], : ); % 3 -> 4
                    m.polfreezebc( ci, :, : ) = transferbc(epfbc,[1 2 4]); % [ epfbc(:,1,:), epfbc(:,2,:)-epfbc(:,3,:), 2*epfbc(:,3,:) ];
                    m.celledges( ci, : ) = [ oe1, ne4, oe3 ];
                    newcellvxs(nc1,:) = [ v4 v5 v1 ];
                    newpolfreeze( nc1, :, : ) = extpolfreeze( :, [4 5 1], : ); % 1 2 3 -> 4 5 1
                    %newpolfreezebc( nc1, :, : ) = extpolfreezebc( :, [4 5 1], : );
                    newpolfreezebc( nc1, :, : ) = transferbc(epfbc,[4 5 1]); % epfbc*[0 0 1;2 -2 1;0 2 -1];
                    m.celledges( numcells+nc1, : ) = [ ne2 ne4 ne3 ];
                    m.edgeends( ne4, : ) = [ v1 v4 ];
                    splitinfo( ci, : ) = [ numcells+nc1, numcells+nc2, 0, ci1, ci2, ci3 ];
                else
                    m.tricellvxs( ci, : ) = [ v1 v2 v5 ];
                    m.polfreeze( ci, :, : ) = extpolfreeze( :, [1 2 5], : );
                    %m.polfreezebc( ci, :, : ) = extpolfreezebc( :, [1 2 5], : );
                    m.polfreezebc( ci, :, : ) = transferbc(epfbc,[1 2 5]);
                    m.celledges( ci, : ) = [ ne4, ne2, oe3 ];
                    newcellvxs(nc1,:) = [ v5 v2 v4 ];
                    newpolfreeze( nc1, :, : ) = extpolfreeze( :, [5 2 4], : );
                    % newpolfreezebc( nc1, :, : ) = extpolfreezebc( :, [5 2 4], : );
                    newpolfreezebc( nc1, :, : ) = transferbc(epfbc,[5 2 4]);
                    m.celledges( numcells+nc1, : ) = [ oe1 ne3 ne4 ];
                    m.edgeends( ne4, : ) = [ v2 v5 ];
                    splitinfo( ci, : ) = [ numcells+nc1, numcells+nc2, -1, ci1, ci2, ci3 ];
                end
                newcellvxs(nc2,:) = [ v5 v4 v3 ];
                newpolfreeze( nc2, :, : ) = extpolfreeze( :, [5 4 3], : );
                %newpolfreezebc( nc2, :, : ) = extpolfreezebc( :, [5 4 3], : );
                newpolfreezebc( nc2, :, : ) = transferbc(epfbc,[5 4 3]); % epfbc*[2 0 -1;0 2 -1;0 0 1];
                newpolfrozen( nc1, : ) = m.polfrozen( ci, : );
                newpolfrozen( nc2, : ) = m.polfrozen( ci, : );
                if size(m.polsetfrozen,1) > 1
                    newpolsetfrozen( [nc1,nc2], : ) = m.polsetfrozen( [ci,ci], : );
                end
                if ~isempty( m.growthangleperFE )
                    newgaPerFE( [nc1,nc2],: ) = m.growthangleperFE( ci,: );
                end
                m.celledges( numcells+nc2, : ) = [ ne1 oe2 ne3 ];
                newcellsmade = newcellsmade+2;
                oldcells([newcellsmade-1, newcellsmade]) = ci;
            case 7 % 1 1 1
                v4 = cellsplits(ci,ci1) + numnodes;
                v5 = cellsplits(ci,ci2) + numnodes;
                v6 = cellsplits(ci,ci3) + numnodes;
                [oe1,ne1] = findsplit( ci, ci1 );
                [oe2,ne2] = findsplit( ci, ci2 );
                [oe3,ne3] = findsplit( ci, ci3 );
                ne4 = curnewedge+1;  % New edge joining v5 and v6.
                ne5 = curnewedge+2;  % New edge joining v4 and v5.
                ne6 = curnewedge+3;  % New edge joining v6 and v4.
                curnewedge = ne6;
                nc1 = curnewcell+1;  % New cell sharing v1 with old cell.
                nc2 = curnewcell+2;  % New cell sharing v2 with old cell.
                nc3 = curnewcell+3;  % New cell sharing v3 with old cell.
                curnewcell = nc3;
                m.edgeends( ne4, : ) = [ v5 v6 ];
                m.edgeends( ne5, : ) = [ v6 v4 ];
                m.edgeends( ne6, : ) = [ v4 v5 ];
                m.tricellvxs( ci, : ) = [ v4 v5 v6 ];
                m.polfreeze( ci, :, : ) = extpolfreeze( :, [4 5 6], : );
                % m.polfreezebc( ci, :, : ) = extpolfreezebc( :, [4 5 6], : );
                m.polfreezebc( ci, :, : ) = transferbc(epfbc,[4 5 6]);
                m.celledges( ci, : ) = [ ne4 ne5 ne6 ];
                newcellvxs(nc1,:) = [ v1 v6 v5 ];
                newpolfreeze( nc1, :, : ) = extpolfreeze( :, [1 6 5], : );
                % newpolfreezebc( nc1, :, : ) = extpolfreezebc( :, [1 6 5], : );
                newpolfreezebc( nc1, :, : ) = transferbc(epfbc,[1 6 5]);
                m.celledges(numcells+nc1,:) = [ ne4 ne2 oe3 ];
                newcellvxs(nc2,:) = [ v2 v4 v6 ];
                newpolfreeze( nc2, :, : ) = extpolfreeze( :, [2 4 6], : );
                %newpolfreezebc( nc2, :, : ) = extpolfreezebc( :, [2 4 6], : );
                newpolfreezebc( nc2, :, : ) = transferbc(epfbc,[2 4 6]);
                m.celledges(numcells+nc2,:) = [ ne5 ne3 oe1 ];
                newcellvxs(nc3,:) = [ v3 v5 v4 ];
                newpolfreeze( nc3, :, : ) = extpolfreeze( :, [3 5 4], : );
                % newpolfreezebc( nc3, :, : ) = extpolfreezebc( :, [3 5 4], : );
                newpolfreezebc( nc3, :, : ) = transferbc(epfbc,[3 5 4]);
                newpolfrozen( [nc1,nc2,nc3], : ) = repmat( m.polfrozen( ci, : ), 3, 1 );
                if size(m.polsetfrozen,1) > 1
                    newpolsetfrozen( [nc1,nc2,nc3], : ) = m.polsetfrozen( [ci,ci,ci], : );
                end
                if ~isempty( m.growthangleperFE )
                    newgaPerFE( [nc1,nc2,nc3],: ) = m.growthangleperFE( ci,: );
                end
                m.celledges(numcells+nc3,:) = [ ne6 ne1 oe2 ];
                splitinfo( ci, : ) = [ numcells+nc1, numcells+nc2, numcells+nc3, ...
                                       ci1, ci2, ci3 ];
                newcellsmade = newcellsmade+3;
                oldcells((newcellsmade-2):newcellsmade) = ci;
        end
    end
    m.tricellvxs = [ m.tricellvxs; newcellvxs ];
    m.polfreeze = [ m.polfreeze; newpolfreeze ];
    m.polfreezebc = [ m.polfreezebc; newpolfreezebc ];
    m.polfrozen = [ m.polfrozen; newpolfrozen ];
    if size(m.polsetfrozen,1) > 1
        m.polsetfrozen = [ m.polsetfrozen; newpolsetfrozen ];
    end

% 4. Rebuild all the other data.

fprintf( 1, '%s 4: rebuild other data.\n', mfilename() );
    m = makecelledges( m );
    m = makeVertexConnections( m );  % Could just recalculate for the affected nodes.
    m.edgesense = edgesense( m );

    % m = extrapolatePerVertexSplits( m, ends );
    
    
    % Per-vertex values.
    pends = [ ends*2-1; ends ];
    if ~isempty(m.displacements)
        m.displacements = extendSplit( m.displacements, pends, 'ave' );
    end
    numnewvxs = length(ends1);
    oldmgens1 = m.morphogens(ends1,:);
    oldmgens2 = m.morphogens(ends2,:);
    newmgens = zeros( length(ends1), size(m.morphogens,2) );
    oldmgenprod1 = m.mgen_production(ends1,:);
    oldmgenprod2 = m.mgen_production(ends2,:);
    newmgenprod = zeros( numnewvxs, size(m.morphogens,2) );
    oldmgenabs1 = m.mgen_absorption(ends1,:);
    oldmgenabs2 = m.mgen_absorption(ends2,:);
    newmgenabs = zeros( numnewvxs, size(m.morphogens,2) );
    for i=1:size(m.morphogens,2)
%         newmgens(:,i) = splitVals( m.morphogens(:,i), ends, m.mgen_interpType{i} );
        switch m.mgen_interpType{i}
            case 'min'
                newmgens(:,i) = min(oldmgens1(:,i), oldmgens2(:,i));
                newmgenprod(:,i) = min(oldmgenprod1(:,i), oldmgenprod2(:,i));
                newmgenabs(:,i) = min(oldmgenabs1(:,i), oldmgenabs2(:,i));
            case 'max'
                newmgens(:,i) = max(oldmgens1(:,i), oldmgens2(:,i));
                newmgenprod(:,i) = max(oldmgenprod1(:,i), oldmgenprod2(:,i));
                newmgenabs(:,i) = max(oldmgenabs1(:,i), oldmgenabs2(:,i));
            otherwise
                newmgens(:,i) = (oldmgens1(:,i) + oldmgens2(:,i))/2;
                newmgenprod(:,i) = (oldmgenprod1(:,i) + oldmgenprod2(:,i))/2;
                newmgenabs(:,i) = (oldmgenabs1(:,i) + oldmgenabs2(:,i))/2;
        end
    end
    
    % Create new vertex normals for the new vertexes.
    % Recalculate the vertex normals for all vertexes of all elements
    % containing split edges.
    m.vertexnormals( end+numnewvxs, end ) = 0;
    m = setMeshVertexNormals( m );
    
    % Obsolete code, from when elements of m.tubules.tubuleparams could be
    % vectors of values, one per I'm not sure what, vertexes or elements.
    % Currently we use morphgoens for this purpose.
%     tpnames = fieldnames( m.tubules.tubuleparams );
%     for i=1:length(tpnames)
%         fn = tpnames{i};
%         if numel( m.tubules.tubuleparams.(fn) ) > 1
%             newvalues = (oldtubuleparams.(fn)(ends1) + oldtubuleparams.(fn)(ends2))/2;
%             m.tubules.tubuleparams.(fn) = [m.tubules.tubuleparams.(fn); newvalues ];
%         end
%     end
    
    m.morphogens = [ m.morphogens; newmgens ];
    m.mgen_production = [ m.mgen_production; newmgenprod ];
    m.mgen_absorption = [ m.mgen_absorption; newmgenabs ];
    m.morphogenclamp = extendSplit( m.morphogenclamp, ends, 'min' );
    m.growthanglepervertex = extendSplit( m.growthanglepervertex, ends, 'ave' );
    if isfield(m, 'growthTensorPerVertex')
        m.growthTensorPerVertex = ...
            extendSplit( m.growthTensorPerVertex, pends, 'ave' );
    end
    
    % Per-FE values.
    
    m.gradpolgrowth = extendHeight( m.gradpolgrowth, numadditionalcells );
    m.gradpolgrowth( (oldnumcells+1):end, :, : ) = m.gradpolgrowth( oldcells, :, : );
    nummgens = size(m.morphogens,2);
    for mi=1:nummgens
        if length(m.conductivity(mi).Dpar)==numcells
            m.conductivity(mi).Dpar = extendHeight( m.conductivity(mi).Dpar, numadditionalcells );
        end
        if length(m.conductivity(mi).Dper)==numcells
            m.conductivity(mi).Dper = extendHeight( m.conductivity(mi).Dper, numadditionalcells );
        end
    end
    if ~isempty( m.growthangleperFE )
        m.growthangleperFE = [ m.growthangleperFE; newgaPerFE ];
    end
    m.effectiveGrowthTensor = extendHeight( m.effectiveGrowthTensor, numadditionalcells );
    if ~isempty(m.directGrowthTensors)
        m.directGrowthTensors = extendHeight( m.directGrowthTensors, numadditionalcells );
    end
    m = makeAreasAndNormals( m );  % Could just recalculate for the new cells.
    m = makebendangles( m );
    newedges = (numedges+numsplits+1) : size(m.edgeends,1);
    newsplits = (numedges+1) : (numedges+numsplits);
    
    % Every new edge must have its initial bend set to its current bend.
    m.initialbendangle(newedges) = m.currentbendangle(newedges);
    m.initialbendangle(newsplits) = m.currentbendangle(es);
    
    % Every old edge across which the bend angle changed has its initial
    % bend set to its current bend.
  % m.initialbendangle(es) = m.currentbendangle(es);
    m.initialbendangle(bentedges) = m.currentbendangle(bentedges);

    if hasNonemptySecondLayer( m )
        m.secondlayer = secondlayerSplitFE( m.secondlayer, splitinfo );
    end
    if ~isempty(m.decorFEs)
        [m.decorFEs, m.decorBCs] = ...
            updateptsSplitFE( m.decorFEs, m.decorBCs, splitinfo );
    end
    
    % Update the seams.
    % An edge is a seam if its ancestor was a seam.
    if ~isempty( m.seams )
        m.seams = [ m.seams; false( size(m.edgeends,1)-length(m.seams), 1 ) ];
       % m.seams = logical([ m.seams; false( size(m.edgeends,1)-length(m.seams), 2) ]); %JAB changed number of columns and force type
        splitseams = es(m.seams( es ));
        m.seams( edgemapping( splitseams ) ) = m.seams( splitseams );
    end
    
    % Update the fixed degrees of freedom.
    % A new node has a DF fixed if and only if both ends of its edge have
    % that DF fixed.
    pends1 = prismIndexes( ends1 );
    pends2 = prismIndexes( ends2 );
    psplits = prismIndexes( (numnodes+1):(numnodes+numsplits) );
    m.fixedDFmap(psplits,:) = ...
        m.fixedDFmap(pends1,:) & m.fixedDFmap(pends2,:);

% 5. Update cell info.
fprintf( 1, '%s 5: update cell info.\n', mfilename() );
    WANTALLTHISSTUFF = true;
    if WANTALLTHISSTUFF
        nc1 = splitinfo(:,1);
        nc2 = splitinfo(:,2);
        nc3 = splitinfo(:,3);
        from1 = nc1 > 0;
        from2 = nc2 > 0;
        from3 = nc3 > 0;
        newci = [nc1(from1); nc2(from2); nc3(from3)];
        oldci = [ find(from1); find(from2); find(from3) ];
        m.celldata(newci) = m.celldata(oldci);
        m.cellFrames(:,:,newci) = m.cellFrames(:,:,oldci);
        if ~isempty( m.cellFramesA )
            m.cellFramesA(:,:,newci) = m.cellFramesA(:,:,oldci);
        end
        if ~isempty( m.cellFramesB )
            m.cellFramesB(:,:,newci) = m.cellFramesB(:,:,oldci);
        end
        m.cellbulkmodulus(newci) = m.cellbulkmodulus(oldci);
        m.cellpoisson(newci) = m.cellpoisson(oldci);
        m.cellstiffness(:,:,newci) = m.cellstiffness(:,:,oldci);

%         m = generateCellData( m, (numcells+1):(numcells+curnewcell) );
%         for ci = 1:length(oldcells)
%             oldcell = oldcells(ci);
%             newcell = oldnumcells + ci;
%             m.celldata(newcell).displacementStrain = m.celldata(oldcell).displacementStrain;
%             m.celldata(newcell).residualStrain = m.celldata(oldcell).residualStrain;
%         end
%         for ci = 1:size(splitinfo,1)
%             if splitinfo(ci,4) ~= 0
%                 ci1 = splitinfo(ci,4);
%                 ci2 = splitinfo(ci,5);
%                 ci3 = splitinfo(ci,6);
%                 m.celldata(ci1).displacementStrain = m.celldata(ci).displacementStrain;
%                 m.celldata(ci1).residualStrain = m.celldata(ci).residualStrain;
%                 if splitinfo(ci,5) ~= 0
%                     m.celldata(ci2).displacementStrain = m.celldata(ci).displacementStrain;
%                     m.celldata(ci2).residualStrain = m.celldata(ci).residualStrain;
%                     if splitinfo(ci,6) ~= 0
%                         m.celldata(ci3).displacementStrain = m.celldata(ci).displacementStrain;
%                         m.celldata(ci3).residualStrain = m.celldata(ci).residualStrain;
%                     end
%                 end
%             end
%         end
    end
    
    m = calculateOutputs( m );
    if isfield( m, 'vertexancestors' )
        m.vertexancestors((numnodes+1):(numnodes+numsplits),:) = [ ends1, ends2 ];
    end
    
% 6. Rebuild streamlines.
    for i=1:length(m.tubules.tracks)
        finaloldvertex = m.tubules.tracks(i).vxcellindex(end);
        [m.tubules.tracks(i).vxcellindex, m.tubules.tracks(i).barycoords] = ...
            updateptsSplitFE( m.tubules.tracks(i).vxcellindex, m.tubules.tracks(i).barycoords, splitinfo );
        [~,m.tubules.tracks(i).directionbc] = ...
            updateptsSplitFE( finaloldvertex, m.tubules.tracks(i).directionbc, splitinfo );  % NOT VALID
        m.tubules.tracks(i).directionglobal = m.tubules.tracks(i).directionbc * m.nodes( m.tricellvxs( m.tubules.tracks(i).vxcellindex(end), : ), : );
    end
    
% 7. Validate the result.
fprintf( 1, '%s 6: validate.\n', mfilename() );
    validmesh(m);

function newbc = transferbc( oldbc, pqr )
    bcx = inv(weights(pqr,:));
    newbc = oldbc;
    for ii=1:size(oldbc,3)
        newbc(:,:,ii) = oldbc(:,:,ii)*bcx;
    end
end

function [oe,ne] = findsplit( ci, cei )
    e1 = m.celledges( ci, cei );
    e2 = edgemapping( e1 );
    if m.edgeends(e1,1)==m.tricellvxs( ci, mod(cei,3)+1 )
        oe = e1;
        ne = e2;
    else
        oe = e2;
        ne = e1;
    end
end
end

% function a = extendSplit( a, ends1, ends2 )
%     a = [ a; (a(ends1,:) + a(ends2,:))/2 ];
% end
% 
% function a = extendMin( a, ends1, ends2 )
%     a = [ a; min( a(ends1,:), a(ends2,:) ) ];
% end
% 
% function a = extendMax( a, ends1, ends2 )
%     a = [ a; max( a(ends1,:), a(ends2,:) ) ];
% end
