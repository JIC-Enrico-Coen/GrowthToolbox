function plotFEmesh( m, varargin )
%plotFEmesh( m, ax )
% THIS IS NEVER CALLED.
%   Plot a new-style finite element mesh.
%   m contains m.FEnodes, which is the set of all vertexes, and m.FEsets, a
%   struct array with one element for each set of FEs of a single type.
%
%   Options:
%
%   'axes'  The axes to plot into, by default the current axes
%   'edges' A number specifying which classes of edges to draw. The greater
%       the number, the more edges are drawn.
%       0: no edges at all
%       1: hull edges that belong to only a single finite element.
%          These are in effect the "border" edges of the older type of mesh.
%       2: All hull edges.
%       3: All hull and surface edges.
%       4: All edges.
%   'faces' A number specifying which classes of faces are drawn.
%       0: No faces.
%       1: All faces for 2D meshes; surface faces for 3D meshes.
%       2: All faces for all meshes.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'axes', [], 'edges', 4, 'faces', 1, 'facealpha', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
            'axes', 'edges', 'faces', 'facealpha' );
    if ~ok, return; end
            
    if isempty( s.axes )
        s.axes = gca();
    end
    if ~ishandle( s.axes )
        return;
    end
    
    full3d = usesNewFEs( m );
    
    if full3d
        fesets = m.FEsets;
    else
        fesets = m.FEsets(1);
    end
    
    if s.edges > 0
        edgeblocks = cell( length(fesets), 1 );
        for i=1:length(fesets)
            feset = fesets(i);
            edgeblocks{i} = reshape( feset.fevxs(:,feset.fe.edges)', 2, [] )';
        end
        edges = sortrows( sort( cell2mat( edgeblocks ), 2 ) );

        switch s.edges
            case 1
                eqseq = all( edges(1:(end-1),:)==edges(2:end,:), 2 );
                isdup = [eqseq;false] | [false;eqseq];
                edges = edges(~isdup,:);
            otherwise
                [edges,ei,ej] = unique( edges, 'rows' );
        end


        edges = edges';
        plot3( reshape( m.FEnodes(edges,1), 2, [] ), ...
              reshape( m.FEnodes(edges,2), 2, [] ), ...
              reshape( m.FEnodes(edges,3), 2, [] ), ...
            '-k', 'Parent', s.axes );
    end
    
    if s.faces > 0
        faceblocks3 = cell( 1, length(fesets) );
        faceblocks4 = cell( 1, length(fesets) );
        for i=1:length(fesets)
            feset = fesets(i);
            faces = feset.fe.faces;
            isface3 = any(faces==0,1);
            faces3 = faces(1:3,isface3);
            faces4 = faces(:,~isface3);
            faceblocks3{i} = reshape( feset.fevxs(:,faces3)', 3, [] );
            faceblocks4{i} = reshape( feset.fevxs(:,faces4)', 4, [] );
        end
        faces3 = cell2mat( faceblocks3 );
        faces4 = cell2mat( faceblocks4 );
        
        switch s.faces
            case 1
                faces3 = uniquesortedrows( faces3' )';
                faces4 = uniquesortedrows( faces4' )';
            case 2
        end
        if ~isempty( faces3 )
            pts = reshape( m.FEnodes( faces3, : ), 3, [], 3 );
            patch( pts(:,:,1), pts(:,:,2), pts(:,:,3), 'r', ...
                'FaceAlpha', s.facealpha, 'EdgeAlpha', 0 );
        end
        if ~isempty( faces4 )
            pts = reshape( m.FEnodes( faces4, : ), 4, [], 3 );
            patch( pts(:,:,1), pts(:,:,2), pts(:,:,3), 'r', ...
                'FaceAlpha', s.facealpha, 'EdgeAlpha', 0 );
        end
    end
end

function x = uniquesortedrows( x )
% Return an array consisting of every row of x which does not have the same
% values, in any order, as any other row of x.  This is used to discover
% faces of an FE mesh which belong to just one FE, i.e. those faces which
% define the exterior surface.  For a mesh of 2D FEs, it would similarly
% find the border edges, although in that case a simpler method is
% possible, as we do not have to preserve the original ordering of
% vertexes within each row.

    if ~isempty(x)
        [xx,xi] = sortrows( sort( x, 2 ) );
        x = x(xi,:);
        eqseq = all( xx(1:(end-1),:)==xx(2:end,:), 2 );
        isdup = [eqseq;false] | [false;eqseq];
        x = x(~isdup,:);
    end
end
