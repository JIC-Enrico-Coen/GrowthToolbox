function m = splitSecondLayerCells( m, splitall )
%m = splitSecondLayerCells( m )
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
%   USER SELECTION: If m.globalProps.bioApresplitproc is a function handle,
%   that function will be called for each cell that passes the COMPETENCE
%   and AREA criteria.  If its do_split result is false, the cell will not
%   be split.  That procedure is also responsible for determing the
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


    if ~hasNonemptySecondLayer( m )
        return;
    end
    
    full3d = isVolumetricMesh( m );

    numsecondcells = length( m.secondlayer.cells );
    if numsecondcells==0, return; end
    
    if m.globalProps.maxBioAcells > 0
        maxsplits = m.globalProps.maxBioAcells - numsecondcells;
        if  maxsplits <= 0
            % No more cells can be created.
            return;
        end
    else
        maxsplits = -1;
    end

    if nargin < 2, splitall = false; end


    USEMINDIAM = true;
    USEPOLGRAD = false;
    USEELLIPSOID = false;
    MINEIGRATIO = 1;
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
        if ~dosplit
            continue;
        end
        haveSplitCentre = usedCallback & ~isempty(dividepoint) & ~any(isnan(dividepoint(:)));
        haveSplitPerp = usedCallback & (any(divideperp(:)) ~= 0) & ~any(isnan(divideperp(:)));
        haveSplitting = haveSplitCentre & haveSplitPerp;
%         if usedCallback
%             usedCallback = any(divideperp(:)) ~= 0;
%             %If divideperp is empty or all zero, the callback did not calculate a splitting.
%         end
        if ~haveSplitting
            % No splitting method specified, so use default.
            if USEMINDIAM
                % [dividepoint,v,distance] = polysplitdiameter( cellcoords(:,[1 2]) );
                [dividepoint1,divideperp1,distance] = polysplitdiameter( cellcoords );
                w = cross(divideperp1,cellNormal);
                if m.globalProps.biosplitnoise > 0
                    p = randInCircle2( m.globalProps.biosplitnoise*distance );
                    dividepoint1 = dividepoint1 + p(1)*divideperp1 + p(2)*w;
                end
                divideperp1 = w;
            elseif USEPOLGRAD
                dividepoint1 = sum( cellcoords, 1 )/numcellvxs;
                pg = m.gradpolgrowth( ...
                        m.secondlayer.vxFEMcell( m.secondlayer.cells(ci).vxs(:) ), ...
                        : );
                divideperp1 = sum(pg,1)'/size(pg,1);
                n = norm(divideperp1);
                covariance = cov( cellcoords );
                [eigs,e] = eig( covariance );
                de = diag(e);
                es = sort(de);
                r = es(2)/es(3);
                if (n <= 0) || (r < MINEIGRATIO)
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
            elseif USEELLIPSOID
                % Split perpendicular to the longest axis of the best-fit
                % ellipsoid.
                dividepoint1 = sum( cellcoords, 1 )/numcellvxs;
                covariance = cov( cellcoords );
                [vv,e] = eig( covariance );
                divideperp1 = vv(:,3);
            else
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
            if (maxsplits > 0) && (numsplits >= maxsplits)
                break;
            end
        end
    end
    
    if any( all( abs(splitcentres) < 1e-5, 2 ) )
        xxxx = 1;
    end
    
    cellsToDivide = cellsToDivide(1:numsplits);
    if numsplits > 0
        fprintf( 1, 'splitSecondLayerCells: %d cells to split:', numsplits );
        fprintf( 1, ' %d', cellsToDivide );
        fprintf( 1, '\n' );
    end
    for i=1:numsplits
        m = splitclonecell( m, cellsToDivide(i), splitdirs(i,:), splitcentres(i,:) );
    end
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
    if ~ok
        fprintf( 1, 'Invalid second layer in %s.\n', mfilename() );
        % error( mfilename() );
    end
end
