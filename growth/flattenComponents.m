function [m,ok] = flattenComponents( m, interactive, method, cpt, bsiters )
%m = flattenComponents( m, interactive, method, cpt, bsiters )
%   Flatten the indicated components of m.  cpt is the index of a component
%   of m, in the arbitrary order in which those components are discovered.
%   It may also be a list of such indexes.  By default, it is all of them.
%   As this is quite a time-consuming operation, the process is animated on
%   the screen (provided that INTERACTIVE is true), with progress indicators.
%
%   If cpt is out of range, it is ignored.
%
%   BSITERS is a parameter determining how hard it tries to flatten each
%   component.  Setting it to zero eliminates the phase of the
%   flattenng process in which, after having laid out the whole mesh in the
%   plane, it tries to adjust the edge lengths to be as close as possible
%   to their lengths in the unflattened mesh.

    if (nargin < 5) || isempty(bsiters)
        bsiters = 500;
    end
    m = setComponentInfo( m );
    numcpts = length(m.componentinfo.nodesets);
    if interactive
        hf = makeFigure(m);
    else
        hf = [];
    end
    if (nargin < 4) || isempty(cpt)
        cpt = 1:numcpts;
    end
    
    deleteCpts = false( 1, numcpts );
    
    m1 = m;
    ok = true;
    oldarea = sum(m1.cellareas);
    for i=cpt
        m1 = flattenComponent( m1, i, hf, method, bsiters );
        if ~isempty(hf)
            h = guidata(hf);
            status = h.status;
            h.status = [];
            guidata(hf,h);
            if ~isempty( status )
                switch status
                    case 'skip'
                        % Nothing
                    case 'skipall'
                        break;
                    case 'delete'
                        deleteCpts(i) = true;
                    case 'cancel'
                        ok = false;
                        break;
                    otherwise
                end
            end
            if strcmp( h.clicked, 'skipallButton' )
                break;
            end
        end
    end
    if ok
        % delete components
        if any( deleteCpts )
            elementsToDelete = false( size( m1.tricellvxs, 1 ) );
            for i=find(deleteCpts)
                elementsToDelete(m1.componentinfo.cellsets{i}) = true;
            end
            m1 = deleteFEs(m1,find(elementsToDelete));
            m1 = setComponentInfo( m1 );  % Inefficient -- should only need to reindex.
        end
        m1 = rearrangeComponents( m1 );
        m1 = recalc3d(m1);
        newarea = sum(m1.cellareas);
        arearatio = oldarea/newarea;
        lineratio = sqrt(arearatio);
        m1.cellareas = m1.cellareas * arearatio;
        m1.nodes = m1.nodes + lineratio;
        m1.prismnodes = m1.prismnodes + lineratio;
        [ok,m1] = validmesh( m1 );
        if ~ok
            complain( '%s yielded an invalid mesh.', mfilename() );
        end
%         rotations = zeros( 3, 3, size( m.tricellvxs, 1 ) );
%         for i=1:size( m.tricellvxs, 1 )
%             vi = 2 * m.tricellvxs( i, : );
%             vi = [ vi-1; vi ];
%             oldvxs = m.prismnodes( vi(:), : );
%             newvxs = m1.prismnodes( vi(:), : );
%             lm = fitmat( oldvxs, newvxs );
%             rotations(:,:,i) = extractRotation( lm );
%         end
        m = m1;
%         m = rotateAllTensors( m, rotations );
    end
%     if ~isempty(hf)
%         close( hf );
%     end
end

function m = rearrangeComponents( m )
    numcpts = length(m.componentinfo.nodesets);
    mx = zeros( numcpts, 2 );
    mn = zeros( numcpts, 2 );
    centre = zeros( numcpts, 2 );
    for i=1:numcpts
        cptnodes = m.nodes( m.componentinfo.nodesets{i}, : );
        mx(i,:) = max( cptnodes(:,[1 2]), [], 1 );
        mn(i,:) = min( cptnodes(:,[1 2]), [], 1 );
        centre(i,:) = (mn(i,:) + mx(i,:))/2;
    end
    margin = 0.05;
    numx = ceil(sqrt(numcpts));
    numy = ceil( numcpts*1.0/numx );
    spacing = max( mx-mn, [], 1 ) * (1+margin);
    startx = -(numx-1)*spacing(1)/2;
    starty = -(numy-1)*spacing(2)/2;
    xi = 0;
    yi = 0;
    translations = zeros( size( m.nodes ) );
    for i=1:numcpts
        nodeset = m.componentinfo.nodesets{i};
        translation = [ [ startx + xi*spacing(1), starty + yi*spacing(2) ] - centre(i,[1 2]), 0 ];
        translations( nodeset, : ) = ones(length(nodeset),1) * translation;
        xi = xi+1;
        if xi >= numx
            xi = 0;
            yi = yi+1;
        end
    end
    m.nodes = m.nodes + translations;
    m.prismnodes = m.prismnodes + reshape( [ translations, translations ]', 3, [] )';
end

function m = flattenComponent( m, cpt, hf, method, bsiters )
    if cpt > length(m.componentinfo.nodesets)
        return;
    end
    squishedMesh = m.nodes( m.componentinfo.nodesets{cpt}, [1 2] );
    c = sum( m.nodes( m.componentinfo.nodesets{cpt}, : ), 1 ) / ...
             length( m.componentinfo.nodesets{cpt} );
    if ~isempty(hf)
        h = guidata(hf);
        if ishandle( h.progressText )
            set( h.progressText, 'String', '' );
            set( h.announceText, 'String', ...
                 sprintf( 'Centroid [%.3f %.3f %.3f]\n', c ) );
            set( hf, 'Name', sprintf( 'Flattening %s, component %d', m.globalProps.modelname, cpt ) );
            if length(m.componentinfo.nodesets{cpt}) <= 3
                set( h.progressText, 'String', sprintf( 'Component has only 3 vertexes.\n' ) );
            end
            set( h.announceText, 'String', 'Laying out boundary.' );
            drawnow;
        end
    end
    
    nodesets = m.componentinfo.nodesets;
    cptnodeindexes = nodesets{cpt};
    cptnodemap = zeros( 1, size(m.nodes,1) ); % This must be a row vector, not a column vector.
    cptnodemap(cptnodeindexes) = 1:length(cptnodeindexes);
    trimap = all( cptnodemap(m.tricellvxs), 2 ) > 0;
    cpttri = cptnodemap( m.tricellvxs( trimap, : )); % This is why.  If cptnodemap were a
                                             % column vector and trimap has
                                             % length 1, then cpttri would
                                             % be 3*1 instead of 1*3.
    oldcptarea = sum( m.cellareas( trimap ) );
    edgesets = m.componentinfo.edgesets;
    cptedgeindexesM = edgesets{cpt};
    cptedgeends = cptnodemap( m.edgeends( cptedgeindexesM, : ) );

    if strcmp( method, 'ballandspring' )
        firstbdnode = 0;
        for i=1:length(cptnodeindexes)
            nce = m.nodecelledges{ cptnodeindexes(i) };
            if nce( 2, size(nce,2) )==0
                firstbdnode = i;
                break;
            end
        end

        [bn,ba,be] = componentBoundary( m, cptnodeindexes(firstbdnode) );
      % interiorindexesM = setdiff( cptnodeindexes, bn );
        vxsflat = layOutPolygon(be,ba);
        if m.globalProps.flattenforceconvex
            [vxsflat,ok] = convexify( vxsflat );
            if ~ok
                fprintf( 1, '%s: warning: boundary layout for component %d could not be made convex.\n', ...
                    mfilename(), cpt );
            end
        end

        xmap = zeros(size(m.nodes,1),1);
        xmap(bn) = 1:length(bn);
        bdedgeends = partedgeends( m.edgeends, bn );
        bdedgeends = xmap(bdedgeends);

        if ~isempty(hf)
            plotsimplemesh( h.plotAxes, vxsflat, bdedgeends );
        end
        % pause

        bnmap = cptnodemap(bn);
        interiornodebitmap = true(length(cptnodeindexes),1);
        interiornodebitmap(bnmap) = false;
        interiorindexes = find(interiornodebitmap);
        centroid = sum(vxsflat,1)/size(vxsflat,1);
        cptnodes = ones(length(cptnodeindexes),1) * centroid;
        cptnodes(bnmap,:) = vxsflat;

        if ~isempty(interiorindexes)
            if ~isempty(hf)
                set( h.announceText, 'String', ...
                     sprintf( 'Adding %d interior nodes.', length(interiorindexes) ) );
                plotsimplemesh( gca, cptnodes, cptedgeends );
                axis equal
                drawnow;
            end

            cptweights = makeweights( m.nodes(cptnodeindexes,:), cptedgeends, 0.5 );
            cptweights = cptweights( interiorindexes, : );
            if ~isempty(hf)
                plotsimplemesh( gca, cptnodes, cptedgeends );
                axis equal
                drawnow;
            end
            iters = 500;
            for i=1:iters
                newinteriorpts = cptweights*cptnodes;
                movements = newinteriorpts - cptnodes(interiorindexes,:);
                cptnodes(interiorindexes,:) = newinteriorpts;
                err = max(abs(movements(:)));
                maxedgelen = sqrt(max(sum( (cptnodes(cptedgeends(:,1),:) - cptnodes(cptedgeends(:,2),:)).^2, 2 )));
                relerr = err/maxedgelen;
                % plotsimplemesh( gca, inodes, m.edgeends(m.componentinto.edgesets{cpi},:) );
                if  (~isempty(hf)) && (mod(i,10)==0)
                    plotsimplemesh( gca, cptnodes, cptedgeends );
                    axis equal
                    set( h.progressText, 'String', sprintf( 'Step %d/%d, err %f relerr %f', ...
                        i, iters, err, relerr ) );
                    drawnow;
                end
                if relerr < 0.001
                    break;
                end
            end
            % pause;
        end
    else
        if size(cpttri,2) ~= 3
            cpttri = cpttri';
        end
        if strcmp( method, 'laplacian' )
            cptnodes = laplacian_flattening( m.nodes( cptnodeindexes, : )', cpttri' )';
        elseif strcmp( method, 'geodesic' )
            cptnodes = geodesic_flattening( m.nodes( cptnodeindexes, : )', cpttri' )';
        end
    end
    newcptarea = sum( triangleareas( cptnodes, cpttri ) );
    ratio = sqrt( oldcptarea/newcptarea );
    cptnodes = cptnodes*ratio;

    if ~isempty(hf)
        set( h.announceText, 'String', 'Equilbrating stresses.' );
        set( h.progressText, 'String', '' );
    end
    cptedgeendsM = cptnodeindexes(cptedgeends);
    restlengths = sqrt(sum( (m.nodes( cptedgeendsM(:,2), : )- m.nodes( cptedgeendsM(:,1), : )).^2, 2 ));
  % cptnodes = cptnodes*5;
    triangles = cptnodemap( m.tricellvxs );
    triangles = triangles( all(triangles > 0, 2), : );
    if bsiters > 0
        [nodes] = ... % , abserr, relerr, stretchchange, numiters] = ...
            BSequilibrate( cptnodes, cptedgeends, restlengths, triangles, ...
                1, 0.1*bsiters, bsiters, 0.001, ...
                hf, @updateBSprogress );
    else
        nodes = cptnodes;
%         abserr = 0;
%         relerr = 0;
%         stretchchange = 0;
%         numiters = 0;
    end
  % fprintf( 1, 'Terminated at %d iters: rel. stretch change %.3f, max resid. strain %.3f.\n', ...
  %     numiters, stretchchange, relerr );

    if false
        trimap = all( cptnodemap(m.tricellvxs), 2 ) > 0; %#ok<UNRCH>
        cpttri = cptnodemap( m.tricellvxs( trimap, : ));
        if size(cpttri,2) ~= 3
            cpttri = cpttri';
        end
        if strcmp( method, 'laplacian' )
            nodes = laplacian_flattening( m.nodes( cptnodeindexes, : )', cpttri' )';
        elseif strcmp( method, 'geodesic' )
            nodes = geodesic_flattening( m.nodes( cptnodeindexes, : )', cpttri' )';
        end
        newcptarea = sum( triangleareas( nodes, cpttri ) );
        ratio = sqrt( oldcptarea/newcptarea );
        nodes = nodes*ratio;
    end
    
    % Rotate the flattened component to align with the XY projection of the
    % original.  This is just for cosmetic purposes.  The flattening
    % transformation introduces an arbitrary rotation, and this removes it.
    lt = fitmat( nodes, squishedMesh );
    rot = extractRotation( lt );
    nodes = nodes*rot;
    
    % Put flattened component into m.
    rotations = tritrirot( m.nodes( cptnodeindexes, : ), ...
                        m.unitcellnormals( trimap, : ), ...
                        [ nodes, zeros( size(nodes,1), 1 ) ], ...
                        repmat( [0 0 1], size(cpttri,1), 1 ), ...
                        cpttri );
    m.nodes( cptnodeindexes, : ) = [ nodes, zeros( size(nodes,1), 1 ) ];
    cptprismnodeindexes = cptnodeindexes*2;
    pdiffs = m.prismnodes(cptprismnodeindexes,:) - m.prismnodes(cptprismnodeindexes-1,:);
    deltas = 0.5*sqrt(sum( (pdiffs).^2, 2 ));
    m.prismnodes(cptprismnodeindexes,:) = [ m.nodes( cptnodeindexes, [1 2] ), deltas ];
    m.prismnodes(cptprismnodeindexes-1,:) = [ m.nodes( cptnodeindexes, [1 2] ), -deltas ];
    
    % Use r to rotate:
    %   m.celldata.(every tensor value)
    % It's difficult to rotate the displacements, because they're
    % per-vertex, not per-cell.
    m = rotateAllTensors( m, permute( rotations, [2,1,3] ), m.componentinfo.cellsets{cpt} );
end

function ee = partedgeends( edgeends, nodeindexes )
%ee = partedgeends( edgeends, nodeindexes )
%   Find the part of edgeends, both members of which are in nodeindexes.

    nodemap = false(max(max(nodeindexes),max(edgeends(:))),1);
    nodemap(nodeindexes) = true;
    ee = edgeends( all(nodemap(edgeends),2), : );
end

function wts = makeweights( nodes, edgeends, a )
    wts = zeros(size(nodes,1));
    if false
        edgewts = ones(size(edgeends,1),1); %#ok<UNRCH>
    else
        edgewts = 1./sqrt(sum( (nodes(edgeends(:,1),:) - nodes(edgeends(:,2),:)).^2, 2 ));
    end
    for i=1:size(edgeends,1)
        j = edgeends(i,1);
        k = edgeends(i,2);
        wts(j,k) = edgewts(i);
        wts(k,j) = edgewts(i);
    end
    weightsums = sum(wts,2);
    for i=1:size(wts,1)
        wts(i,:) = wts(i,:)/weightsums(i);
    end
    wts = a*wts + (1-a)*eye(size(wts));
end

function layoutFigure( hf, eventData ) %#ok<INUSD>
    if ~ishandle(hf), return; end
    h = guidata(hf);
    if ~ishandle(h.skipButton), return; end
    hfpos = get( hf, 'Position' );
    windowwidth = hfpos(3);
    windowheight = hfpos(4);
    margin = 20;
    buttonheight = 22;
    buttonwidth = 60;
    textheight = 20;
    axismarksheight = 20;
    % Buttons at the bottom in a row.
    curxpos = margin;
    curypos = margin;
    set( h.skipButton, 'Position', [ curxpos, curypos, buttonwidth, buttonheight ] );
    curxpos = curxpos + buttonwidth + margin;
    set( h.skipallButton, 'Position', [ curxpos, curypos, buttonwidth, buttonheight ] );
    curxpos = curxpos + buttonwidth + margin;
    set( h.deleteButton, 'Position', [ curxpos, curypos, buttonwidth, buttonheight ] );
    curxpos = curxpos + buttonwidth + margin;
    set( h.cancelButton, 'Position', [ curxpos, curypos, buttonwidth, buttonheight ] );
    
    % Text items in a column.
    curxpos = margin;
    curypos = curypos + margin + textheight;
    set( h.progressText, 'Position', [curxpos curypos windowwidth-margin textheight] );
    curypos = curypos + textheight;
    set( h.announceText, 'Position', [curxpos curypos windowwidth-margin textheight] );
    
    % Plot takes up the remainder of the space.
    curypos = curypos+textheight+margin+axismarksheight;
    plotheight = windowheight - curypos - margin;
    set( h.plotAxes, 'Position', [margin curypos windowwidth-margin-margin plotheight] );
end

function hf = makeFigure( m )
    bgColor = [0.831373 0.815686 0.784314];
    hf = figure( 'Name', ['Flattening ', m.globalProps.modelname], ...
                 'NumberTitle', 'off', ...
                 'Color', bgColor, ...
                 'IntegerHandle', 'off' );
    hfpos = get( hf, 'Position' );
    ha = axes('Tag', 'plotAxes', ...
              'Parent',hf, ...
              'Units', 'pixels', ...
              'Position', [10 70 hfpos(3)-20 hfpos(4)-80], ...
              'DataAspectRatio', [1 1 1], ...
              'DataAspectRatioMode', 'manual' );
    ht1 = uicontrol( 'Tag', 'announceText', ...
                     'Parent',hf, ...
                     'Style', 'text', ...
                     'String', 'Announcements', ...
                     'Units', 'pixels', ...
                     'HorizontalAlignment', 'left', ...
                     'Position', [10 25 hfpos(3)-20 20], ...
                     'BackgroundColor', bgColor );
    ht2 = uicontrol( 'Tag', 'progressText', ...
                     'Parent',hf, ...
                     'Style', 'text', ...
                     'String', 'Progress', ...
                     'Units', 'pixels', ...
                     'HorizontalAlignment', 'left', ...
                     'Position', [10 5 hfpos(3)-20 20], ...
                     'BackgroundColor', bgColor );
    buttons = makeButtons( hf, ...
                           'skipButton', 'Skip', ...
                           'skipallButton', 'Skip All', ...
                           'deleteButton', 'Delete', ...
                           'cancelButton', 'Cancel' ...
                         );
    handles = struct( 'figure', hf, ...
                      'clicked', [], ...
                      'status', 'normal', ...
                      'plotAxes', ha, ...
                      'announceText', ht1, ...
                      'progressText', ht2 );
    handles = setFromStruct( handles, buttons );
    guidata( hf, handles );
    set( hf, 'ResizeFcn', @layoutFigure );
    layoutFigure( hf, [] );
end

function s = makeButtons( hf, varargin )
    bgColor = [0.831373 0.815686 0.784314];
    s = struct();
    for i=1:2:length(varargin)-1
        tag = varargin{i};
        str = varargin{i+1};
        b = uicontrol( 'Tag', tag, ...
                       'Parent',hf, ...
                       'Style', 'pushbutton', ...
                       'String', str, ...
                       'Units', 'pixels', ...
                       'HorizontalAlignment', 'center', ...
                       'Position', [10 25 60 20], ...
                       'BackgroundColor', bgColor, ...
                       'Callback', @buttonClick );
        s.(tag) = b;
    end
end

function status = updateBSprogress( fig, progdata )
    if isempty(fig)
        return;
    end
    handles = guidata( fig );
    set( handles.progressText, 'String', ...
         sprintf( '%d/%d rel. stretch change %f target %f\n', ...
             progdata.iter, progdata.iters, progdata.relstretchchange, progdata.target ) );
    if isempty(handles.clicked)
        handles.status = [];
    else
        switch handles.clicked
            case 'skipButton'
                handles.status = 'skip';
            case 'skipallButton'
                handles.status = 'skipall';
            case 'deleteButton'
                handles.status = 'delete';
            case 'cancelButton'
                handles.status = 'cancel';
            otherwise
                handles.status = [];
        end
        handles.clicked = [];
    end
    status = handles.status;
    guidata( handles.figure, handles );
  % fprintf( 1, 'updateBSprogress %s\n', handles.status );
end

function buttonClick( hObject, eventData ) %#ok<INUSD>
    handles = guidata( hObject );
    buttonName = get( hObject, 'Tag' );
    if ~isfield( handles, buttonName )
        return;
    end
  % fprintf( 1, 'buttonClick %s\n', buttonName );
    handles.clicked = buttonName;
    guidata( hObject, handles );
end

