function m = splitSecondLayerCells( m, splitall, splitmethod )
%m = splitSecondLayerCells( m, splitall, splitmethod )
%   Split all second layer cells satisfying certain criteria.
%   If SPLITALL is true, then all cells are split.
%
%   Otherwise, the choice of cells to split depends on three criteria:
%   competence, area, and the user's custom procedure for determining
%   whether to split a cell.  A cell must pass all three tests in order to
%   be split.
%
%   COMPETENCE: This is decided in one of two ways.  If the DIV_COMP cell
%   factor role is defined, a cell will not be split if the value of that
%   cell factor is less than 0.5.  Otherwise, an older and perhaps obsolete
%   method will be used: if the ARREST morphogen reaches or exceeds the
%   value of m.globalProps.biosplitarrestmgenthreshold, the cell will not
%   be split.  Note that DIV_COMP and ARREST have opposite senses: DIV_COMP
%   must be high to allow splitting, while ARREST must be low.  If no cell
%   factor has the DIV_COMP role and ARREST is zero everywhere, all cells
%   are competent to split.
%
%   AREA: This is decided by the first of these three methods that applies:
%
%   1.  If the DIV_AREA cell factor role is defined, a cell will not be
%   split if its area is less than that cell factor.
%
%   2.  Otherwise, if m.globalProps.biosplitarea is positive (by default it
%   is zero), a cell will not be split unless its area reaches or exceeds
%   it.
%
%   3.  Otherwise, if m.secondlayer.averagetargetarea is positive (which by
%   default it is), a cell is large enough to split if
%       cellarea * cellarrest <= m.secondlayer.averagetargetarea * 1.414
%   where cellarrest is the average of the ARREST morphogen, if it is in
%   use, otherwise 1.
%
%   4.  Otherwise, no cell is excluded on the grounds of area.
%
%   USER SELECTION: If the interaction function defines a function
%   GFtbox_Precelldivision_Callback, or if m.globalProps.bioApresplitproc
%   is a function handle,
%   that function will be called for each cell that passes the COMPETENCE
%   and AREA criteria.  If its do_split result is false, the cell will not
%   be split.  That procedure is also responsible for determining the
%   placement of the new cell wall for cells that should split.
%
%   The default for a new mesh is that:
%   * No cell factor has the DIV_COMP role.
%   * ARREST is everywhere zero.
%   * m.globalProps.biosplitarea is zero.
%   * m.secondlayer.averagetargetarea is the initial average cell area.
%   * m.globalProps.bioApresplitproc is empty.
%   This means that cells are split whenever they reach an area of
%   m.secondlayer.averagetargetarea * 1.414.
%
%   Note that the ARREST morphogen should be considered obsolete.
%
%   When running a simulation, this procedure is normally called after the
%   growth phase.  If the growth morphogens are all zero everywhere, or if
%   growth is disabled, then this procedure is not called.


    m.secondlayer.edgelineage = zeros(0,1,'int32');

    if ~hasNonemptySecondLayer( m )
        return;
    end
    
    if size( m.secondlayer.vxFEMcell, 1 ) == 1
        xxxx = 1;
    end

    full3d = isVolumetricMesh( m );

    numsecondcells = length( m.secondlayer.cells );
    if numsecondcells==0, return; end
    
    if m.globalProps.maxBioAcells > 0
        maxsplits = m.globalProps.maxBioAcells - numsecondcells;
        if maxsplits <= 0
            % No more cells can be created.
            return;
        end
    else
        maxsplits = Inf;
    end

    if nargin < 2
        splitall = false;
    end

    if nargin < 3
        % Alternatives are 'mindiam', 'polgrad', and 'ellipsoid'.
        % Use the value set in m.
        splitmethod = m.globalProps.bioAsplitmethod;
    end

    numcells = length( m.secondlayer.cells );
    
    for ci=1:numcells
        m.secondlayer.cells(ci).vxs = m.secondlayer.cells(ci).vxs(:)';
    end
    
    if splitall
        splitPermitted = true(numcells,1);
    else
        [~, rolefactors] = name2Index( m.secondlayer.cellfactorroles, 'DIV_COMP', 'DIV_AREA' );
        if rolefactors(1) ~= 0
            divcomp = m.secondlayer.cellvalues(:,rolefactors(1)) > 0.5;
        else
            divcomp = true( numcells,1);
        end

        arrestMgenIndex = FindMorphogenIndex( m, m.globalProps.biosplitarrestmgen );
        arrestMgen = getEffectiveMgenLevels( m, arrestMgenIndex );
        haveArrest = ~isempty( arrestMgenIndex );
        if haveArrest
            haveArrest = any( arrestMgen >= m.globalProps.biosplitarrestmgenthreshold );
        end
        if haveArrest
            cellarrest = perVertexToPerCell( m, arrestMgen );
            arrestAllowed = cellarrest < m.globalProps.biosplitarrestmgenthreshold;
        else
            cellarrest = 1;
            arrestAllowed = true( numsecondcells, 1 );
        end

        if rolefactors(2) ~= 0
            divarea = m.secondlayer.cellvalues(:,rolefactors(2)) < m.secondlayer.cellarea;
        else
            if m.globalProps.biosplitarea > 0
                divarea = m.secondlayer.cellarea >= m.globalProps.biosplitarea;
            elseif m.secondlayer.averagetargetarea > 0
                divarea = m.secondlayer.cellarea .* cellarrest > m.secondlayer.averagetargetarea * 1.414;
            else
                divarea = true( numsecondcells, 1 );
            end
        end
        
        splitPermitted = divcomp & arrestAllowed & divarea;
        
        if ~any(splitPermitted)
            return;
        end
    end

    splitcentres = zeros(0,3);
    splitdirs = zeros(0,3);
    numsplits = 0;
    cellsToDivide = zeros(1,numsecondcells);
    for ci=1:numsecondcells
        if ~splitPermitted(ci)
            continue;
        end

        secondlayer_vxs = m.secondlayer.cells(ci).vxs;
        numcellvxs = length(secondlayer_vxs);
        cellcoords = m.secondlayer.cell3dcoords( secondlayer_vxs, : );
        if full3d
            [cellCentroid,cellNormal,cellFlatness] = bestFitPlane( cellcoords );
        else
            cellFEs = m.secondlayer.vxFEMcell( secondlayer_vxs );
            cellNormal = sum( m.unitcellnormals( cellFEs, : ), 1 )/numcellvxs;
            cellNormal = cellNormal/norm(cellNormal);
        end

        dosplit = true;
        dividepoint = [];
        divideperp = [];
        
        usedCallback = false;
        
        if m.globalProps.newcallbacks
            [m,result] = invokeIFcallback( m, 'Precelldivision', ci );
            usedCallback = true;
            if ~isempty(result)
                if isfield( result, 'divide' )
                    dosplit = result.divide;
                end
                if isfield( result, 'dividepoint' )
                    dividepoint = result.dividepoint;
                end
                if isfield( result, 'perpendicular' )
                    divideperp = result.perpendicular;
                end
            end
        end
        if ~usedCallback && isa( m.globalProps.bioApresplitproc, 'function_handle' )
            [m,dosplit,dividepoint,divideperp] = m.globalProps.bioApresplitproc( m, ci );
            usedCallback = true;
        end
        if dosplit==0
            continue;
        end
        haveSplitCentre = usedCallback & ~isempty(dividepoint) & ~any(isnan(dividepoint(:)));
        haveSplitPerp = usedCallback & (any(divideperp(:) ~= 0)) & ~any(isnan(divideperp(:)));
        haveSplitting = haveSplitCentre & haveSplitPerp;
        if ~haveSplitting
            % No splitting method specified, so use default.
            switch splitmethod
                case 'mindiam'
                    [dividepoint1,divideperp1] = splitPolyMinDiam( cellcoords, cellNormal, m.globalProps.biosplitnoise );
                case 'polgradif'
                    cellvxsFEM = m.secondlayer.vxFEMcell( m.secondlayer.cells(ci).vxs(:) );
                    cellvxsPolGrad = m.gradpolgrowth( cellvxsFEM, : );
                    [dividepoint1,divideperp1] = splitPolyDirection2( cellcoords, cellvxsPolGrad, 0.9, true );
                case 'polgradbest'
                    cellvxsFEM = m.secondlayer.vxFEMcell( m.secondlayer.cells(ci).vxs(:) );
                    cellvxsPolGrad = m.gradpolgrowth( cellvxsFEM, : );
                    [dividepoint1,divideperp1] = splitPolyDirection( cellcoords, cellvxsPolGrad, 1, false );
                case 'polgradpar'
                    cellvxsFEM = m.secondlayer.vxFEMcell( m.secondlayer.cells(ci).vxs(:) );
                    cellvxsPolGrad = m.gradpolgrowth( cellvxsFEM, : );
                    [dividepoint1,divideperp1] = splitPolyDirection( cellcoords, cellvxsPolGrad, 0, true );
                case 'polgradperp'
                    cellvxsFEM = m.secondlayer.vxFEMcell( m.secondlayer.cells(ci).vxs(:) );
                    cellvxsPolGrad = m.gradpolgrowth( cellvxsFEM, : );
                    [dividepoint1,divideperp1] = splitPolyDirection( cellcoords, cellvxsPolGrad, 0, false );
                case 'ellipsoid'
                    [dividepoint1,divideperp1] = splitEllipsoid( cellcoords, cellvxsPolGrad );
                case 'minpolwalls'
                    % Find the line parallel to polgrad through the centroid.
                    % Find the two walls that it intersects.
                    % Find the shortest path through the centroid between those walls.
                otherwise
                    % No splitting method, so do not split.
                    dosplit = false;
            end
            if dosplit
                if ~haveSplitCentre
                    dividepoint = dividepoint1;
                end
                if ~haveSplitPerp
                    divideperp = divideperp1;
                end
            end
        end
        if dosplit
            numsplits = numsplits+1;
            cellsToDivide(numsplits) = ci;
            divideperp = divideperp + 0.0*rand(size(divideperp));
            splitdirs(numsplits,:) = divideperp';
            splitcentres(numsplits,:) = dividepoint;
            if numsplits >= maxsplits
                break;
            end
        end
    end
    
    if any( all( abs(splitcentres) < 1e-5, 2 ) )
        xxxx = 1;
    end
    
    cellsToDivide = cellsToDivide(1:numsplits);
    if numsplits > 0
        timedFprintf( 1, '%d cells to split:', numsplits );
        fprintf( 1, ' %d', cellsToDivide );
        fprintf( 1, '\n' );
    end
    
    oldnumedges = getNumberOfCellEdges( m );
    numnewedges = 3*numsplits;
    m.secondlayer.edgelineage = [ int32(1:oldnumedges)'; zeros(numnewedges,1,'int32') ];
    if ~isfield( m.secondlayer, 'edgeattriblength' ) || isempty( m.secondlayer.edgeattriblength )
        m.secondlayer.edgeattriblength = celledgelengths(m);
    end
    if any( m.secondlayer.edgeattriblength==0 )
        xxxx = 1;
    end
    m.secondlayer.edgeattriblength = [ m.secondlayer.edgeattriblength; zeros(numnewedges,1) ];
    
    % m.secondlayer.edgeattriblength contains, for every edge of the
    % current mesh, the length that it would have had in the mesh before
    % growth. For new cell walls, that is their current length. For cell
    % walls that have been split, we consider the proportion of the edge
    % that each daughter edge takes up, multiplied by the length that the
    % split edge had before growth.
    
    xxsplitdata = zeros(numsplits,5);
    xxsplitalpha = zeros(numsplits,4);
    numactualsplits = 0;
    for i=1:numsplits
        [m,edgesplitdata] = splitclonecell( m, cellsToDivide(i), splitdirs(i,:), splitcentres(i,:) );
        if ~isempty(edgesplitdata)
            numactualsplits = numactualsplits+1;
            m.secondlayer.edgelineage( edgesplitdata.newei1 ) = edgesplitdata.sei1;
            m.secondlayer.edgelineage( edgesplitdata.newei2 ) = edgesplitdata.sei2;
            els = celledgelengths(m, ...
                            [ edgesplitdata.sei1, ...
                              edgesplitdata.sei2, ...
                              edgesplitdata.newei1, ...
                              edgesplitdata.newei2, ...
                              edgesplitdata.newei3 ] );
            ol1 = els(1)+els(3);
            alpha1 = els(1)/ol1;
            beta1 = 1 - alpha1;
            ol2 = els(2)+els(4);
            alpha2 = els(2)/ol2;
            beta2 = 1 - alpha2;
            
            if any( [ alpha1, beta1, alpha2, beta2 ]==0 )
                xxxx = 1;
            end
            
            m.secondlayer.edgeattriblength(edgesplitdata.newei1) = m.secondlayer.edgeattriblength(edgesplitdata.sei1) * beta1;
            m.secondlayer.edgeattriblength(edgesplitdata.sei1) = m.secondlayer.edgeattriblength(edgesplitdata.sei1) * alpha1;
            m.secondlayer.edgeattriblength(edgesplitdata.newei2) = m.secondlayer.edgeattriblength(edgesplitdata.sei2) * beta2;
            m.secondlayer.edgeattriblength(edgesplitdata.sei2) = m.secondlayer.edgeattriblength(edgesplitdata.sei2) * alpha2;
            m.secondlayer.edgeattriblength(edgesplitdata.newei3) = celledgelengths( m, edgesplitdata.newei3 ); % New edges are not allowed to shrink.
            
            xxsplitdata(numactualsplits,:) = [ edgesplitdata.sei1, edgesplitdata.sei2, edgesplitdata.newei1, edgesplitdata.newei2, edgesplitdata.newei3 ];
            xxsplitalpha(numactualsplits,:) = [ alpha1, beta1, alpha2, beta2 ];
            xxxx = 1;
        else
            xxxx = 1;
        end
    end
    if numactualsplits < numsplits
        m.secondlayer.edgeattriblength( (oldnumedges + 3*numactualsplits + 1):end ) = [];
    end
    if any( m.secondlayer.edgeattriblength==0 )
        xxxx = 1;
    end
    
    xxxx = 1;
    
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
    if ok
        m = leaf_refinebioedges( m );
    end
    if ~ok
        timedFprintf( 1, 'Invalid second layer.\n' );
        xxxx = 1;
    end
    
    if size( m.secondlayer.vxFEMcell, 1 ) == 1
        xxxx = 1;
    end

end

function [dividepoint1,divideperp1] = splitPolyDirection( cellcoords, dir, mineigratio, par )
    % Split parallel or perpendicular to the gradient of polariser.
    % If the eigenvalue ratio for the cell is below mineigratio, then split
    % either parallel or perpendicular to dir, depending on which is closer
    % to the long axis. Otherwise, split along dir.
    
    numcellvxs = size( cellcoords, 1 );
    dividepoint1 = sum( cellcoords, 1 )/numcellvxs;
    divideperp1 = sum(dir,1)'/size(dir,1);
    
    covariance = cov( cellcoords );
    [eigs,e] = eig( covariance );
    de = diag(e);
    es = sort(de);
    if ~par
        cellnormal = eigs(:,1);
        divideperp1 = cross( divideperp1, cellnormal );
    end
    n = norm(divideperp1);
    r = es(2)/es(3);
    if r < mineigratio
        cellaxis = eigs(:,3);
        va = vecangle( divideperp1', cellaxis' );
        theta = abs(abs(va) - pi/2);
        if theta < pi/4
            divideperp1 = makeperp( divideperp1, cellaxis );
            divideperp1 = divideperp1/norm(divideperp1);
        elseif n > 0
            divideperp1 = divideperp1/n;
        else
            divideperp1 = cellaxis;
        end
    else
        divideperp1 = divideperp1/n;
    end
end

function [dividepoint1,divideperp1] = splitPolyDirection2( cellcoords, dir, mineigratio, par )
    % Split parallel or perpendicular to the gradient of polariser.
    % If the eigenvalue ratio for the cell is below mineigratio, then split
    % by the shortest wall, otherwise split parallel or perpendicular to
    % dir.
    
    numcellvxs = size( cellcoords, 1 );
    dividepoint1 = sum( cellcoords, 1 )/numcellvxs;
    divideperp1 = sum(dir,1)'/size(dir,1);
    
    covariance = cov( cellcoords );
    [eigs,e] = eig( covariance );
    de = diag(e);
    es = sort(de);
    r = es(2)/es(3);
    timedFprintf( 1, 'eigratio = %g\n', r );
    cellnormal = eigs(:,1);
    if r < mineigratio
        % Split by shortest wall.
        [dividepoint1,divideperp1] = splitPolyMinDiam( cellcoords, cellnormal, 0 );
    else
        % Split par or perp.
        if ~par
            divideperp1 = cross( divideperp1, cellnormal );
        end
        n = norm(divideperp1);
        divideperp1 = divideperp1/n;
    end
end

function [dividepoint1,divideperp1] = splitEllipsoid( cellcoords )
    % Split perpendicular to the longest axis of the best-fit
    % ellipsoid.
    numcellvxs = size( cellcoords, 1 );
    dividepoint1 = sum( cellcoords, 1 )/numcellvxs;
    covariance = cov( cellcoords );
    [vv,e] = eig( covariance );
    divideperp1 = vv(:,3);
end

