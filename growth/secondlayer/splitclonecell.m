function [m,edgesplitdata] = splitclonecell( m, ci, v, splitpoint )
%[m,edgesplitdata] = splitclonecell( m, ci, v, splitpoint )
%m = splitclonecell( m, ci, v )
%   Split cell ci perpendicular to direction v, through splitpoint.
%   splitpoint defaults to the centroid of the vertexes.

%   One new cell, two new vertexes, and three new edges are created.

%   dumpsecondlayer( m.secondlayer );

    edgesplitdata = [];
    
    if all(v==0) || any(isnan(v))
        return;
    end
    
    % Should pull-in be implemented for edges that do not have a cell on
    % both sides?  Currently not.
    pullRim = false;
    
    % Force edges to be split at least this absolute distance from their endpoints.
    min_d = m.globalProps.biosplitavoid4way * sqrt(m.secondlayer.averagetargetarea/1.4);

    VERBOSE = 0;
    if VERBOSE
        fprintf( 1, 'splitclonecell: splitting cell %d.\n', ci );
    end
    
    % Find out how many of everything there is, and get the cell vertex
    % coordinates.
    numcells = length( m.secondlayer.cells );
    numvertexes = length( m.secondlayer.vxFEMcell );
    numedges = size( m.secondlayer.edges, 1 );
    cell3dcoords = m.secondlayer.cell3dcoords( m.secondlayer.cells(ci).vxs, : );
    numcellvxs = size( cell3dcoords, 1 );
    

    if nargin < 4
        splitpoint = sum( cell3dcoords, 1 )/numcellvxs;
    end

    [split1cv1,split1cv2,newvx3d1,split2cv1,split2cv2,newvx3d2] = splitPoly( v, splitpoint, cell3dcoords );
    if split1cv1 == 0
        fprintf( 1, ...
            '%s: Error: cell %d is not split by a plane through the splitpoint: c (%.3f %.3f %.3f) v (%.3f %.3f %.3f).\n', ...
            mfilename(), ci, splitpoint, v );
        return;
    end
    splitvxs = m.secondlayer.cells(ci).vxs( [ split1cv1, split1cv2, split2cv1, split2cv2 ] );
    splitedgeindexes = m.secondlayer.cells(ci).edges( [ split1cv1, split2cv1 ] );
    splitedgedata = m.secondlayer.edges( splitedgeindexes, : );
    % Create indexes for the new cell, edges, and vertexes.
    newci = numcells+1;
    newvi1 = numvertexes+1;
    newvi2 = numvertexes+2;
    newei1 = numedges+1;
    newei2 = numedges+2;
    newei3 = numedges+3;
    
    % Edges sei1 and sei2 were split. Each is the index of one of its
    % daughter edges, and newei1 and newei2 are their respective other
    % daughter edges. newei3 is the new cell wall.
    edgesplitdata = struct( 'sei1', splitedgeindexes(1), ...
                            'sei2', splitedgeindexes(2), ...
                            'newei1', newei1, ...
                            'newei2', newei2, ...
                            'newei3', newei3 );
    
    lastGeneration = m.secondlayer.generation( length(m.secondlayer.generation) );
    m.secondlayer.generation([newei1,newei2,newei3]) = ...
         [ m.secondlayer.generation(splitedgeindexes(1));
           m.secondlayer.generation(splitedgeindexes(2));
           lastGeneration + 1 ];
    m.secondlayer.edgepropertyindex([newei1,newei2,newei3]) = ...
         [ m.secondlayer.edgepropertyindex(splitedgeindexes(1));
           m.secondlayer.edgepropertyindex(splitedgeindexes(2));
           m.secondlayer.newedgeindex ];
    m.secondlayer.interiorborder([newei1,newei2,newei3]) = false;
    % Find the cells that lie on the other side of each of the edges to be
    % split.
    otherci1 = splitedgedata( 1, 3 );
    if otherci1==ci
        otherci1 = splitedgedata( 1, 4 );
    end
    
    otherci2 = splitedgedata( 2, 3 );
    if otherci2==ci
        otherci2 = splitedgedata( 2, 4 );
    end
    
    % Find the intersections of the split edges with the cutting plane.
    % These are the new vertexes.
    edgeendCoords = m.secondlayer.cell3dcoords( splitvxs, : );
%     newvx3d1 = v1; % lineplaneIntersection( edgeendCoords(1,:), edgeendCoords(2,:), v, splitpoint )
%     newvx3d2 = v2; % lineplaneIntersection( edgeendCoords(3,:), edgeendCoords(4,:), v, splitpoint )

    newvx3d1 = avoidEnds( newvx3d1, edgeendCoords(1,:), edgeendCoords(2,:), min_d );
    newvx3d2 = avoidEnds( newvx3d2, edgeendCoords(3,:), edgeendCoords(4,:), min_d );

    b = m.globalProps.bioApullin;
    a = 1 - b;
    if (~pullRim) && (otherci1 <= 0)
        adjnewvx3d1 = newvx3d1;
    else
        adjnewvx3d1 = a*newvx3d1 + b*newvx3d2;
    end
    if (~pullRim) && (otherci2 <= 0)
        adjnewvx3d2 = newvx3d2;
    else
        adjnewvx3d2 = a*newvx3d2 + b*newvx3d1;
    end
    newvx3d1 = adjnewvx3d1;
    newvx3d2 = adjnewvx3d2;
    
    % Find the parent FEM cell and barycentric coordinates for the first
    % new vertex.
    % Find which FEM cells the edge endpoints are in.
    femCells = m.secondlayer.vxFEMcell( splitvxs );
    if VERBOSE
        fprintf( 1, 'femCells %d %d\n', femCells );
    end
    if 0
        [ testvi1, testbc1 ] = splitcloneedge( m, splitedgeindexes(1) );
        [ testvi2, testbc2 ] = splitcloneedge( m, splitedgeindexes(2) );
    end
    if 0 && (testvi1 <= 0) && (testvi2 <= 0)
        fprintf( 1, 'splitclonecell: new method used for cell %d.\n', ci );
        newcell1 = testvi1;
        bc1 = testbc1;
    else
        if femCells(1)==femCells(2)
            newcell1 = femCells(1);
            bc1 = cellBaryCoords( m, newcell1, newvx3d1 );
        else
            [ newcell1, bc1, err ] = findFE( m, newvx3d1, 'hint', femCells(1:2) );
        end
        if VERBOSE
            fprintf( 1, 'newcell1 %d\n', newcell1 );
        end
    end
    
    if isempty(bc1)
        % Error: cannot find new point.
        fprintf( 1, 'splitclonecell: cannot find edge midpoint 1.  err %.3f vx3d1 (%.3f %.3f %.3f), cells %d %d\n', ...
            err, newvx3d1, femCells(1:2));
        return;
    end
    
    % Find the parent FEM cell and barycentric coordinates for the second
    % new vertex.
    if 0 && (testvi1 <= 0) && (testvi2 <= 0)
        newcell2 = testvi2;
        bc2 = testbc2;
    else
        if femCells(3)==femCells(4)
            newcell2 = femCells(3);
            bc2 = cellBaryCoords( m, newcell2, newvx3d2 );
        else
            [ newcell2, bc2, err ] = findFE( m, newvx3d2, 'hint', femCells(3:4) );
        end
        if VERBOSE
            fprintf( 1, 'newcell2 %d\n', newcell2 );
        end
    end
    
    if isempty(bc2)
        % Error: cannot find new point.
        fprintf( 1, 'splitclonecell: cannot find edge midpoint 2.  err %.3f vx3d2 (%.3f %.3f %.3f), cells %d %d\n', ...
            err, newvx3d2, femCells(3:4));
        return;
    end

    % Create the new vertexes.
    m.secondlayer.vxFEMcell(newvi1) = newcell1;
    m.secondlayer.vxBaryCoords(newvi1,:) = normaliseBaryCoords( bc1 );
    m.secondlayer.vxFEMcell(newvi2) = newcell2;
    m.secondlayer.vxBaryCoords(newvi2,:) = normaliseBaryCoords( bc2 );
    if isfield( m.secondlayer, 'surfaceVertexes' )
        newSurfaceVxs = all( m.secondlayer.surfaceVertexes( splitvxs([1 2;3 4]) ), 2 );
        m.secondlayer.surfaceVertexes([newvi1,newvi2]) = newSurfaceVxs;
        surfVxsToMove = [newvi1,newvi2];
        surfVxsToMove = surfVxsToMove( newSurfaceVxs );
        m.secondlayer.vxBaryCoords(surfVxsToMove,:) = moveToSurface( m, surfVxsToMove );
    end
    
    
    % Create the new edges, and modify the existing ones.
    m.secondlayer.edges(newei1,:) = [ newvi1, splitvxs(2), newci, otherci1 ];
    m.secondlayer.edges(newei2,:) = [ newvi2, splitvxs(4), ci, otherci2 ];
    m.secondlayer.edges(newei3,:) = [ newvi1, newvi2, ci, newci ];
    m.secondlayer.edges(splitedgeindexes(1),:) = [ splitvxs(1), newvi1, ci, otherci1 ];
    m.secondlayer.edges(splitedgeindexes(2),:) = [ splitvxs(3), newvi2, newci, otherci2 ];
    if split2cv2 <= split1cv1
        oldrange = split2cv2:split1cv1;
    else 
        oldrange = [split2cv2:numcellvxs, 1:split1cv1];
    end
    if split1cv2 <= split2cv1
        newrange = split1cv2:split2cv1;
    else 
        newrange = [split1cv2:numcellvxs, 1:split2cv1];
    end
    if VERBOSE
        fprintf( 1, 'newei1 %d data [ %d %d %d %d ]\n', newei1, m.secondlayer.edges(newei1,:) );
        fprintf( 1, 'newei2 %d data [ %d %d %d %d ]\n', newei2, m.secondlayer.edges(newei2,:) );
        fprintf( 1, 'newei3 %d data [ %d %d %d %d ]\n', newei3, m.secondlayer.edges(newei3,:) );
    end
    % Create the new cell's vertex and edge lists.
    m.secondlayer.cells(newci).vxs = ...
        [ reshape( m.secondlayer.cells(ci).vxs( newrange ), 1, [] ), newvi2, newvi1 ];
    m.secondlayer.cells(newci).edges = ...
        [ reshape( m.secondlayer.cells(ci).edges( newrange ), 1, [] ), newei3, newei1 ];
    if VERBOSE
        fprintf( 1, 'newci %d vxs [', newci );
        fprintf( 1, ' %d', m.secondlayer.cells(newci).vxs );
        fprintf( 1, ' ]\n' );
        fprintf( 1, 'newci %d edges [', newci );
        fprintf( 1, ' %d', m.secondlayer.cells(newci).edges );
        fprintf( 1, ' ]\n' );
    end

    % Make the new cell's edges refer to the new cell.
    neis = m.secondlayer.cells(ci).edges( newrange );
    ed = m.secondlayer.edges(neis,3:4);
    ed(ed==ci) = newci;
    m.secondlayer.edges(neis,3:4) = ed;
    if VERBOSE
        fprintf( 1, 'newci %d edge data [\n', newci );
        fprintf( 1, '    v %d e %d: %d %d %d %d\n', ...
            [ m.secondlayer.cells(newci).vxs; ...
              m.secondlayer.cells(newci).edges; ...
              m.secondlayer.edges(m.secondlayer.cells(newci).edges,:)' ] );
        fprintf( 1, ' ]\n' );
    end
    % Modify the old cell's vertex and edge lists.
    m.secondlayer.cells(ci).vxs = ...
        [ m.secondlayer.cells(ci).vxs( oldrange ), newvi1, newvi2 ];
    m.secondlayer.cells(ci).edges = ...
        [ m.secondlayer.cells(ci).edges( oldrange ), newei3, newei2 ];
    if VERBOSE
        fprintf( 1, 'ci %d edge data [\n', ci );
        fprintf( 1, '    v %d e %d: %d %d %d %d\n', ...
            [ m.secondlayer.cells(ci).vxs(:); ...
              m.secondlayer.cells(ci).edges; ...
              m.secondlayer.edges(m.secondlayer.cells(ci).edges,:)' ] );
        fprintf( 1, ' ]\n' );
    end

    % Insert the new vertexes and edges into otherci1 and otherci2.
    % Find splitvxs(1:2) in otherci1.vxs.  Insert newvi1 between.
    % Insert newei1 one place before.
    if otherci1 > 0
        numouter1vxs = length(m.secondlayer.cells(otherci1).vxs);
        i = find( m.secondlayer.cells(otherci1).vxs==splitvxs(2), 1 );
        i1 = mod(i,numouter1vxs) + 1;
        if m.secondlayer.cells(otherci1).vxs(i1) == splitvxs(1)
            if VERBOSE
                fprintf( 1, 'Same orientation for cell otherci1 %d.\n', otherci1 );
            end
            m.secondlayer.cells(otherci1).vxs = ...
                [ m.secondlayer.cells(otherci1).vxs(1:i), ...
                  newvi1, ...
                  m.secondlayer.cells(otherci1).vxs(i+1:numouter1vxs) ];
            m.secondlayer.cells(otherci1).edges = ...
                [ m.secondlayer.cells(otherci1).edges(1:i-1), ...
                  newei1, ...
                  m.secondlayer.cells(otherci1).edges(i:numouter1vxs) ];
        else
            if VERBOSE
                fprintf( 1, 'Opposite orientation for cell otherci1 %d.\n', otherci1 );
            end
            m.secondlayer.cells(otherci1).vxs = ...
                [ m.secondlayer.cells(otherci1).vxs(1:i-1), ...
                  newvi1, ...
                  m.secondlayer.cells(otherci1).vxs(i:numouter1vxs) ];
            m.secondlayer.cells(otherci1).edges = ...
                [ m.secondlayer.cells(otherci1).edges(1:i-1), ...
                  newei1, ...
                  m.secondlayer.cells(otherci1).edges(i:numouter1vxs) ];
        end
    end

      
    % Repeat for the other cell.
    if otherci2 > 0
        numouter2vxs = length(m.secondlayer.cells(otherci2).vxs);
        i = find( m.secondlayer.cells(otherci2).vxs==splitvxs(4), 1 );
        i1 = mod(i,numouter2vxs) + 1;
        if m.secondlayer.cells(otherci2).vxs(i1) == splitvxs(3)
            if VERBOSE
                fprintf( 1, 'Same orientation for cell otherci2 %d.\n', otherci2 );
            end
            m.secondlayer.cells(otherci2).vxs = ...
                [ m.secondlayer.cells(otherci2).vxs(1:i), ...
                  newvi2, ...
                  m.secondlayer.cells(otherci2).vxs(i+1:numouter2vxs) ];
            m.secondlayer.cells(otherci2).edges = ...
                [ m.secondlayer.cells(otherci2).edges(1:i-1), ...
                  newei2, ...
                  m.secondlayer.cells(otherci2).edges(i:numouter2vxs) ];
        else
            if VERBOSE
                fprintf( 1, 'Opposite orientation for cell otherci2 %d.\n', otherci2 );
                fprintf( 1, 'otherci2 %d cellvxs [', otherci2 );
                fprintf( 1, ' %d', m.secondlayer.cells(otherci2).vxs );
                fprintf( 1, ' ]\n' );
                fprintf( 1, 'otherci2 %d celledges [', otherci2 );
                fprintf( 1, ' %d', m.secondlayer.cells(otherci2).edges );
                fprintf( 1, ' ]\n' );
                fprintf( 1, 'otherci2 %d edge data [\n', otherci2 );
                fprintf( 1, '    %d %d %d %d\n', m.secondlayer.edges(m.secondlayer.cells(otherci2).edges,:)' );
                fprintf( 1, ' ]\n' );
            end
            m.secondlayer.cells(otherci2).vxs = ...
                [ m.secondlayer.cells(otherci2).vxs(1:i-1), ...
                  newvi2, ...
                  m.secondlayer.cells(otherci2).vxs(i:numouter2vxs) ];
            m.secondlayer.cells(otherci2).edges = ...
                [ m.secondlayer.cells(otherci2).edges(1:i-1), ...
                  newei2, ...
                  m.secondlayer.cells(otherci2).edges(i:numouter2vxs) ];
            if VERBOSE
                fprintf( 1, 'otherci2 %d cellvxs [', otherci2 );
                fprintf( 1, ' %d', m.secondlayer.cells(otherci2).vxs );
                fprintf( 1, ' ]\n' );
                fprintf( 1, 'otherci2 %d celledges [', otherci2 );
                fprintf( 1, ' %d', m.secondlayer.cells(otherci2).edges );
                fprintf( 1, ' ]\n' );
                fprintf( 1, 'otherci2 %d edge data [\n', otherci2 );
                fprintf( 1, '    %d %d %d %d\n', m.secondlayer.edges(m.secondlayer.cells(otherci2).edges,:)' );
                fprintf( 1, ' ]\n' );
            end
        end
%         if 0
%             if m.secondlayer.cells(otherci2).vxs(i1) ~= splitvxs(3)
%                 i1 = i-1;  if i1==0, i1 = numouter2vxs; end
%                 if m.secondlayer.cells(otherci2).vxs(i1) == splitvxs(3)
%                     fprintf( 1, 'Warning: orientation violation for cells %d and %d.\n', ci, otherci2 );
%                     i = i1;
%                 else
%                     fprintf( 1, 'Warning: inconsistency for cells %d and %d.\n', ci, otherci2 );
%                 end
%             end
%             m.secondlayer.cells(otherci2).vxs = ...
%                 [ m.secondlayer.cells(otherci2).vxs(1:i), ...
%                   newvi2, ...
%                   m.secondlayer.cells(otherci2).vxs(i+1:numouter2vxs) ];
%             m.secondlayer.cells(otherci2).edges = ...
%                 [ m.secondlayer.cells(otherci2).edges(1:i-1), ...
%                   newei2, ...
%                   m.secondlayer.cells(otherci2).edges(i:numouter2vxs) ];
%         end
    end
    
    m = calcCloneVxCoords( m, [newvi1,newvi2] );
    if ~isempty( m.secondlayer.cellcolor )
        numcolorparams = size( m.globalProps.colorparams, 1 );
        if (m.secondlayer.cloneindex( ci ) == 0) ...
                || (numcolorparams < m.secondlayer.cloneindex( ci ))
            newcolor = m.secondlayer.cellcolor( ci, : );
        else
            if numcolorparams==1
                colorindex = 1;
            else
                colorindex = m.secondlayer.cloneindex( ci );
                if colorindex > numcolorparams
                    colorindex = numcolorparams;
                end
            end
            if true
                newcolor = randcolornear( 1, ...
                                m.secondlayer.cellcolor( ci, : ), ...
                                m.globalProps.colorvariation );
                if VERBOSE
                    fprintf( 1, 'old [ %.3f %.3f %.3f ]\nnew [ %.3f %.3f %.3f ]  %f\n\n', ....
                        m.secondlayer.cellcolor( ci, : ), ...
                        newcolor, m.globalProps.colorvariation );
                end
            else
                newcolor = secondlayercolor( 1, ...
                	m.globalProps.colorparams( colorindex, : ) );
            end
        end
        m.secondlayer.cellcolor( newci, : ) = newcolor;
    end

    m.secondlayer.visible.cells( newci ) = m.secondlayer.visible.cells( ci );
    m.secondlayer.celltargetarea( newci ) = m.secondlayer.celltargetarea( ci );
    m.secondlayer.areamultiple( newci ) = m.secondlayer.areamultiple( ci );
    m.secondlayer.cloneindex( newci ) = m.secondlayer.cloneindex( ci );
    m.secondlayer.side( newci, 1 ) = m.secondlayer.side( ci, 1 );
    m.secondlayer.cellarea( ci ) = polyarea3( ...
            m.secondlayer.cell3dcoords( m.secondlayer.cells(ci).vxs, : ) );
    m.secondlayer.cellarea( newci ) = polyarea3( ...
            m.secondlayer.cell3dcoords( m.secondlayer.cells(newci).vxs, : ) );
    m.secondlayer.cellvalues(newci,:) = m.secondlayer.cellvalues(ci,:);
    if ~isempty( m.secondlayer.cellpolarity )
        m.secondlayer.cellpolarity(newci,:) = m.secondlayer.cellpolarity(ci,:);
    end
    m.secondlayer = extendCellIndexing( m.secondlayer );
    % Set up cell/edge/vertex data for the new items.  Mostly NOT
    % IMPLEMENTED. The only part we implement is the inheritance of values.
    m.secondlayer.celldata.values(newci,:) = m.secondlayer.celldata.values(ci,:);
    m.secondlayer.edgedata.values(newei1,:) = m.secondlayer.edgedata.values(splitedgeindexes(1),:);
    m.secondlayer.edgedata.values(newei2,:) = m.secondlayer.edgedata.values(splitedgeindexes(2),:);
    m.secondlayer.edgedata.values(newei3,:) = 0;
    m.secondlayer.edgepropertyindex([newei1,newei2]) = m.secondlayer.edgepropertyindex(splitedgeindexes([1 2]));
    m.secondlayer.edgepropertyindex(newei3) = m.secondlayer.newedgeindex;
    m.secondlayer.interiorborder(newei1) = m.secondlayer.interiorborder(splitedgeindexes(1));
    
    % Update the cell id and lineage fields.
    timeAtMidStep = m.globalDynamicProps.currenttime + m.globalProps.timestep/2;
    if timeAtMidStep < 0
        xxxx = 1;
    end
    timeAtEndStep = m.globalDynamicProps.currenttime + m.globalProps.timestep;
        % timeAtMidStep is the time at which a cell division is deemed to
        % have occurred.
    oldcellid = m.secondlayer.cellid(ci);
    maxcellid = length( m.secondlayer.cellparent );
    newcellids = maxcellid + [1 2];
    m.secondlayer.cellid([ci,newci]) = newcellids;
    m.secondlayer.cellparent(newcellids) = oldcellid;
    m.secondlayer.cellidtoindex([oldcellid,newcellids]) = [0,ci,newci];
    m.secondlayer.cellidtotime(oldcellid,2) = timeAtMidStep;
    m.secondlayer.cellidtotime(newcellids,1) = timeAtMidStep;
    m.secondlayer.cellidtotime(newcellids,2) = timeAtEndStep;
    agefactor = FindCellRole( m, 'CELL_AGE' );
    if agefactor ~= 0
        m.cellvalues([ci,newci],agefactor) = 0;
    end
    
    if any(m.secondlayer.cellidtotime(:) < 0)
        xxxx = 0;
    end
    
%     % At this point the following variables are valid:
%     % newvx3d1, newvx3d2: 3d locations of the new vertexes.
%     % ci, newci: the indexes of the two daughter cells. ci was also the
%     % index of the parent cell.
%     % newvi1, newvi2: indexes of the two new vertexes.
%     % newei3: index of the new edge.
%     
%     % Subdivide the new edge if necessary.
%     newedgevec = newvx3d1 - newvx3d2;
%     newedgelength = norm( newedgevec );
%     numdivs = round( newedgelength/m.globalProps.bioAsublength );
%     if numdivs >= 2
%         % Find the 3d positions of the new vertexes.
%         b = linspace( 0, 1, numdivs+1 )';
%         b([0 end] ) = [];
%         a = 1-b;
%         newvxs3d = newvx3d1 * a + newvx3d2 * b;
%         
%         % Find the elements and barycoords of the new vertexes.
%         % If the edge lies within a single element, then the barycentric
%         % coords of the new vertexes can be found by interpolation.
%         % Otherwise they must be found by findFE.
%         % In this case the hint elements will be those of newvx3d1,
%         % newvx3d2, and then of all the other vertexes of the two cells.
%         
%         % Add the new vertexes.
%         
%         % Make and add the new edges.
%         
%         % In each of the cells that the new edge belongs to, insert the new
%         % edges and vertexes into the cells.
%     end

    if m.globalProps.newcallbacks
        [m,~] = invokeIFcallback( m, 'Postcelldivision', ...
                    ci, length(m.secondlayer.cells(ci).edges) - 1, ...
                    newci, length(m.secondlayer.cells(newci).edges) - 1, ...
                    splitedgeindexes(1), splitedgeindexes(2), newei1, newei2, newei3 );
    elseif isa( m.globalProps.bioApostsplitproc, 'function_handle' )
        m = m.globalProps.bioApostsplitproc( m, ...
                ci, length(m.secondlayer.cells(ci).edges) - 1, ...
                newci, length(m.secondlayer.cells(newci).edges) - 1, ...
                splitedgeindexes(1), splitedgeindexes(2), newei1, newei2, newei3 );
    end
end

function p0 = avoidEnds( p0, p1, p2, min_d )
    d11 = norm( p0 - p1 );
    d12 = norm( p0 - p2 );
    d = norm( p2 - p1 );
    minalpha = min( min_d/d, 0.5 );
    
    alpha = 0;
    beta = 0;
    if d11==0
        alpha = 1 - minalpha;
        beta = minalpha;
    elseif d12==0
        alpha = minalpha;
        beta = 1 - minalpha;
    elseif d11/d12 < minalpha
        alpha = 1 - minalpha;
        beta = minalpha;
    elseif d12/d11 < minalpha
        alpha = minalpha;
        beta = 1 - minalpha;
    end
    if alpha > 0
        p0 = alpha*p1 + beta*p2;
    end
end

function newbcs = moveToSurface( m, surfVxsToMove )
    oldbcs = m.secondlayer.vxBaryCoords( surfVxsToMove, : );
    newbcs = oldbcs;
    % One method would be to find the intersection of the cell normal with
    % the surface.
    % Another would be to find which of the FE's vertexes are interior.  If
    % there are any non-interior vertexes, set the bcs for the interior
    % vertexes to zero and renormalise.  Otherwise, revert to the first
    % method.
    fes = m.secondlayer.vxFEMcell( surfVxsToMove );
    fevxs = m.FEsets.fevxs(fes,:);
    interiorfevxs = m.FEconnectivity.vertexloctype( fevxs )==0;
    for i=1:length(surfVxsToMove)
        if all(interiorfevxs(i,:))
            xxxx = 1;
        else
            newbcs(i,interiorfevxs(i,:)) = 0;
            newbcs(i,:) = newbcs(i,:)/sum(newbcs(i,:));
        end
    end
end