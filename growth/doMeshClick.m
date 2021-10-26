function doMeshClick( varargin )
    if nargin < 1, return; end
    hitObject = varargin{1};
    handles = guidata( hitObject );
    if ~isstruct(handles)
        % Not running in GFtbox.
        return;
    end
    if (~isfield( handles, 'mesh' )) || isempty( handles.mesh )
        return;
    end
    if isfield( handles, 'runFlag' ) && get( handles.runFlag, 'Value' )
        beep;
        fprintf( 1, '** Cannot edit leaf while simulation in progress.\n' );
        return;
    end
    parent = get( hitObject, 'Parent' );
    [pt, bc, faceiout] = mySelect3d( varargin{:} );
    if isempty( pt )
        return;
    end
    ud = get( hitObject, 'Userdata' );
    vi = [];
    ei = [];
    ci = [];
    if isfield( ud, 'faces' )
%         fprintf( 1, '%s: faceiout %d, length(ud.faces) %d\n', ...
%             mfilename(), faceiout, length(ud.faces) );
        ci = ud.faces(faceiout);
        [~,cei] = min(bc);
        ei = handles.mesh.celledges(ci,cei);
        [~,cvi] = max(bc);
        vi = handles.mesh.tricellvxs(ci,cvi);
    elseif isfield( ud, 'edges' )
        ei = ud.edges(faceiout);
        ci = handles.mesh.edgecells(ei,1);
        cvi1 = find( handles.mesh.celledges(ci,:)==ei );
        if length(bc)==4
            edgebc = [ bc(1)+bc(4), bc(2)+bc(3) ];
        elseif length(bc)==2
            edgebc = [ bc(1), bc(2) ];
        end
        [~,ebci] = max(edgebc);
        vi = handles.mesh.edgeends(ei,ebci);
        bc = zeros(1,3);
        bc( [cvi1 mod(cvi1,3)+1 mod(cvi1+1,3)+1] ) = [ 0, edgebc ];
%       [~,cvi] = max(bc);
    elseif isfield( ud, 'vxs' )
        vi = ud.vxs(faceiout);
    end
    selectionType = getSelectionType( hitObject );

    output = handles.output;
    mousemode = getMouseModeFromGUI( handles );
    switch mousemode
        case '----'
            % Should forward.
          % GFtboxGraphicClickHandler( handles.picture, [] );
        case ''
            % Nothing.
        case 'mouseeditmodeMenu:Delete element'
            attemptCommand( handles, false, true, ... % WARNING: Does not always need redraw.
                'deletepatch', ci );
            handles = guidata( output );
            handles = GUIPlotMesh( handles );
        case 'bioBedit'
            attemptCommand( handles, false, false, ...
                'addbioregion', ci );
            handles = guidata( output );
            handles = GUIPlotMesh( handles );
        case 'mouseeditmodeMenu:Subdivide edge'
            fprintf( 1, '** Manual subdivision of edges not implemented yet.\n' );
            % Subdivide the cell into four, and split each of the
            % neighbouring cells.
        case 'mouseeditmodeMenu:Subdivide element'
            fprintf( 1, '** Manual subdivision of elements not implemented yet.\n' );
            % Subdivide the cell into four, and split each of the
            % neighbouring cells.
        case { 'morpheditmodemenu:Add', 'morpheditmodemenu:Set', 'morpheditmodemenu:Fix', ...
               'mouseeditmodeMenu:Fix nodes', 'mouseeditmodeMenu:Locate node', ...
               'mouseeditmodeMenu:Subdivide node' }
            % Really a vertex click.
            % Find the hit point and take the closest vertex.
%             [~,cvi] = max(bc);
%             vi = handles.mesh.tricellvxs(ci,cvi);
            handles = vertexClick( handles, vi, selectionType );
        case 'mouseCellModeMenu:Add cell'
            % Not implemented yet.
        case 'mouseCellModeMenu:Delete cell'
            % Not implemented yet.
        case 'simulationMouseModeMenu:Show value'
            if ~isempty( handles.mesh.plotdata )
                if handles.mesh.plotdata.pervertex
                    % Find the hit point and take the closest vertex.
%                     [~,cvi] = max(bc);
%                     vi = handles.mesh.tricellvxs(ci,cvi);
                    handles = vertexClick( handles, vi, selectionType );
                else
                    % Come here if the plot mode is per-cell and display
                    % the value for the hit cell.
                    
                    handles = cellClick( handles, ci, bc, pt, selectionType );
                end
            end
        case { 'mouseeditmodeMenu:Seam edges', 'mouseeditmodeMenu:Subdivide edge', 'mouseeditmodeMenu:Elide edge', 'mouseeditmodeMenu:Elide cell pair' }
            % Really an edge click.
            % Find the hit point and take the closest edge = the most
            % distant vertex.
%             [~,cei] = min(bc);
%             ei = handles.mesh.celledges(ci,cei);
            handles = edgeClick( handles, ei, selectionType );
        otherwise
            fprintf( 1, 'doMeshClick: unknown action %s.\n', ...
                mousemode );
    end

    guidata( parent, handles );
end
