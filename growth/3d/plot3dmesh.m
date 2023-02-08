function [m,h,g] = plot3dmesh( m, ax, perVertexQuantity, perFEQuantity )
%[m,h,g] = plot3dmesh( m, ax, perVertexQuantity, perFEQuantity )
%   Plot a general mesh of finite elements.
%   h is a set of handles to the graphic items created.
%   g is a Geometry object describing the plotted mesh.

    if nargin < 3
        perVertexQuantity = [];
    end
    if nargin < 4
        perFEQuantity = [];
    end
    
    g = meshTo3DModel( m, 'pervertex', perVertexQuantity, 'perFE', perFEQuantity );
    if isempty(g)
        fprintf( 1, '**** Problem getting geometry information from mesh, not plotted.\n' );
    else
        [~,h] = g.draw( ax );
%         delete(g);
        [lw,ls,vw,vs] = basicLineStyle( 1, 0 );
        set( h, 'ButtonDownFcn', @GFtboxGraphicClickHandler );
        handletypes = get( h, 'Type' );
        patches = strcmpi( 'patch', handletypes );
        lines = strcmpi( 'line', handletypes );
        set( h(patches), ...
            'FaceLighting', m.plotdefaults.lightmode, ...
            'AmbientStrength', m.plotdefaults.ambientstrength, ...
            'LineStyle', 'none', ...
            'Marker', 'none' );
        set( h(lines), ...
            'LineWidth', lw, ...
            'LineStyle', ls, ...
            'MarkerSize', vw, ...
            'Marker', vs );
        
        if m.plotdefaults.drawedges==1
            if isfield( m.plotdefaults, 'edgesharpness' ) && ~isempty( m.plotdefaults.edgesharpness )
                edgeAngles = mesh3DSurfaceEdgeAngles( m );
                sharpEdges = edgeAngles >= m.plotdefaults.edgesharpness;
                edgesToDraw = sharpEdges & m.visible.surfedges;

                [lw,ls] = basicLineStyle( m.plotdefaults.FEthinlinesize );
                h = plotlines( m.FEconnectivity.edgeends( edgesToDraw, : ), m.FEnodes, ...
                               'Parent', m.pictures(1), 'LineWidth', lw, 'LineStyle', ls, 'color', m.plotdefaults.FElinecolor );
            elseif isfield( m, 'sharpedges' ) && (length( m.sharpedges ) == size(m.FEconnectivity.edgeends,1))
                edgevxs = m.FEconnectivity.edgeends( m.sharpedges, : );
                v1 = m.FEnodes(edgevxs(:,1),:);
                v2 = m.FEnodes(edgevxs(:,2),:);
                m.plothandles.sharpEdges = plotPtsToPts( ...
                   v1, v2, ...
                  'LineWidth', lw, ...
                  'LineStyle', ls, ...
                  'Color', m.plotdefaults.FElinecolor, ...
                  ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
                  'Parent', ax, ...
                  'ButtonDownFcn', @GFtboxGraphicClickHandler );
                setPlotHandleData( m, 'sharpEdges', 'edges', find(m.sharpedges), 'ButtonDownFcn', @doMeshClick );
            end
        end
    end
    return;
    

    commonpatchargs = { 'Parent', theaxes, ...
                        'FaceLighting', s.lightmode, ...
                        'AmbientStrength', s.ambientstrength, ...
                        'FaceAlpha', s.alpha, ...
                        'EdgeAlpha', s.alpha, ...
                        'EdgeColor', s.FElinecolor };
%                       'LineSmoothing', m.plotdefaults.linesmoothing };  % LineSmoothing is deprecated.
    
    % OLD CODE, TO BE EVENTUALLY DUMPED.
    
    pervertex = isempty( perFEQuantity );
    if pervertex && isempty( perVertexQuantity )
        perVertexQuantity = zeros( size( m.FEnodes, 1 ), 1 );
    end
    if isempty(m.visible) || all(m.visible.nodes)
        % Everything is visible.  The FEconnectivity structure already
        % records which faces are on the surface.
        allVisFaces = m.FEconnectivity.faces( m.FEconnectivity.faceloctype==1, : );
    else
        % Only some nodes are visible.  We draw a face if and only if it is
        % a face of exactly one visible element.  An element is visible if
        % and only if all of its vertexes are visible.
        
        % Find all FEs whose vertexes are all visible.
        visFEs = all(m.visible.nodes(m.FEsets.fevxs),2);
        
        if ~any(visFEs)
            return;
        end
        
        % Find all the faces of those FEs.
        localfaces = m.FEsets.fe.faces;
        allVisFaces = reshape( m.FEsets.fevxs(visFEs,localfaces'), [], size(localfaces,1) );
        
        % Find all repeated faces and remove them.
        allVisFaces = sortrows( sort( allVisFaces, 2 ) );
        repeats = all( allVisFaces(1:(end-1),:)==allVisFaces(2:end,:), 2 );
        repeats = [repeats;false] | [false;repeats];
        allVisFaces = allVisFaces(~repeats,:);
        
        % IF m.FEconnectivity included an 'fefaces' field, recording the
        % faces of all FEs, we could do the above slightly more simply by
        % stipulating that a visible face is one that occurs exactly once
        % in m.FEconnectivity.fefaces(visFEs,:).
    end
    
    
    % Select those faces that belong to exactly one visible FE.
    
%     allfaces = m.FEconnectivity.faces( m.FEconnectivity.faceloctype==1, : )';
%     allfaces(allfaces==0) = NaN;
%     visfaces = all(m.visible.nodes(allfaces),1);
%     allfaces(:,visfaces) = [];
    
    if pervertex
        data = perVertexQuantity;
    else
        data = perFEQuantity;
    end
    s = struct( 'cmap', m.plotdefaults.cmap, 'crange', m.plotdefaults.crange );
    h = plotmeshsurface( [], ax, s, m.FEnodes, allVisFaces, data, pervertex, 1, 0, {'FaceAlpha', m.plotdefaults.alpha}, [] );
end
