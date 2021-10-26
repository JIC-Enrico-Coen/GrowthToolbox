function [g,gvxs,gfaces,gfacefes] = meshTo3DModel( m, varargin )
%[g,gvxs,gfaces] = meshTo3DModel( m, ... )
%   Convert a mesh to geometry and material properties, which can then be
%   written to any 3D file format.  The geometry consists of only the
%   surface faces of the mesh, consistently oriented so that their default
%   normals point to the outside.
%
%   If the mesh is clipped, then only the visible part is exported.
%
%   Colour information will be exported for whatever it currently being
%   plotted: you will get what you see in the GFtbox viewport.
%
%   Limitations:
%
%   1.  Decorations (i.e. polariser gradients, tensor axes, etc.) are not
%   	exported.
%
%   2.  Biological cells are not exported.
%
%   The other results connect g with the original mesh m.
%   This is currently valid only for volumetric meshes.
%
%   ALL OF THE INDEX ARRAYS IN g ARE ZERO-INDEXED (UNLIKE MATLAB).  This is
%   mainly because the Geometry structure that this uses is taken from
%   another project where zero-indexing was more convenient.
%
%   The result is a structure with these fields:
%
%   g.vxs       V*3 array of double.  The vertex positions.
%   g.normal    N*3 array of double.  Normal vectors (optional).
%   g.facevxs   F*any array of integer.  For each face, a list of its
%               vertex indexes.  Faces need not all have the same number of
%               vertexes.  Unused elements are NaN and are always at the
%               end of each row.
%   g.facenormal  F*any array of integer (optional).  For each face, a list
%               of the indexes of the vertex normals at each corner.  This
%               is NaN exactly where g.facevxs is NaN.
%   g.color     C*3 array of double (optional).  A set of colours.
%   g.vxcolor   V*1 array of int32.  Associates a colour index with each
%               vertex.
%   g.facecolor F*1 array of int32.  Associates a colour index with each
%               face.
%   g.facevxcolor F*any array of int32.  Associates a colour index with
%               each corner of each face.
%
%   "Optional" fields are always present, but should be empty when they are
%   unused.
%
%   Only one of vxcolor, facecolor, and facevxcolor should be nonempty.
%
%   Options:
%
%   'pervertex'   Data to be plotted per vertex.  This can be either a
%                 colour, which will be used directly, or a single value
%                 per vertex, which will be converted to a color according
%                 to m.plotoptions.cmap and m.plotoptions.crange.
%   'perFE'       Data to be plotted per finite element.  A colour of a
%                 single value per element, as for pervertex.
%   'triangulate' Force the output to consist of triangles only, by
%                 triangulating every larger polygon. The chosen
%                 triangulation will be arbitrary; no attempt will be made
%                 to find a "good" triangulation. By default this is false.
%   'color'       Export colour information (by default true). If this is
%                 false, no color information is exported.
%   'optimisation'  If 0, no optimisation is done. If 1, invisible
%                 vertexes are discarded from the returned structure. If 2,
%                 vertex positions, alpha values, colors, and normal
%                 vectors will all be unique. No tolerance is applied: the
%                 values must match exactly to be merged. The default value
%                 is 1.
%
%   If neither pervertex nor perFE is specified, then the quantity
%   currently being plotted will be used.  It is an error to specify both.
%
%   GVXS is an array listing for every vertex of G which vertex of M is
%   comes from.
%
%   GFACES does the same for the faces of g.
%
%   GFACEFES maps faces of G to finite elements of M that they belong to.

    g = Geometry();
    gvxs = [];
    gfaces = [];
    gfacefes = [];
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok
        return;
    end
    setGlobals();
    s = defaultfields( s, 'pervertex', [], 'perFE', [], 'triangulate', false, 'color', true, 'optimisation', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'pervertex', 'perFE', 'triangulate', 'color', 'optimisation' );
    if ~ok
        return;
    end
    
    if s.color
        if isempty(s.pervertex) && isempty(s.perFE)
            [colors,~,~,isPerVertex] = meshColors( m );
        else
            isPerVertex = ~isempty(s.pervertex);
            if isPerVertex
                data = s.pervertex;
            else
                data = s.perFE;
            end
            if size(data,2)==1
                colors = meshColors( m, data );
            else
                colors = data;
            end
        end
    else
        colors = zeros(0,3);
        isPerVertex = false;
    end
    
    is3d = isVolumetricMesh( m );
    numvxs = getNumberOfVertexes(m);
    numFEs = getNumberOfFEs(m);
    
    if isempty(m.visible)
        visnodes = true(1,numvxs);
        viselements = true(1,numFEs);
    else
        visnodes = m.visible.nodes;
        if is3d
            viselements = m.visible.elements;
        else
            viselements = m.visible.cells;
        end
    end

    if ~is3d
        if isempty(m.visible)
            visborderedges = m.edgecells(:,2) > 0;
        else
            visborderedges = m.visible.borderedges;
        end
        if m.plotdefaults.thick
            vispnodes = 2*find(visnodes);
            vxs = [m.prismnodes( vispnodes-1, : ); m.prismnodes( vispnodes, : ) ];
            colors = [ colors; colors ];
            cellsA = m.tricellvxs(viselements,:);
            cellsB = cellsA + numvxs;
            cellsA = cellsA(:,[1 3 2]);
            bordercelledges = m.celledges( viselements, : );
            borderedgesA = [ cellsA( visborderedges( bordercelledges(:,1) ), [2 3] );
                             cellsA( visborderedges( bordercelledges(:,2) ), [3 1] );
                             cellsA( visborderedges( bordercelledges(:,3) ), [1 2] ) ];
            borderquads = [ borderedgesA (borderedgesA(:,[2 1])+numvxs) ];
            numviscells = size(cellsA,1);
            polys = [ [ [ cellsA; cellsB ] zeros( numviscells*2, 1 ) ]; borderquads ];
        else
            vxs = m.nodes( visnodes, : );
            polys = m.tricellvxs(viselements,:);
        end
        g = Geometry( 'vxs', vxs, ...
                      'facevxs', polys-1, ...
                      'color', colors, ...
                      'alpha', m.plotdefaults.alpha );
        if s.triangulate
            triangulate( g, false );
        end
    else    
        if isempty(m.visible)
            % Everything is visible.  The FEconnectivity structure already
            % records which faces are on the surface.
    %             allVisFaces = m.FEconnectivity.faces( m.FEconnectivity.faceloctype==1, : );
        else
        end

        % Only some nodes are visible.  We draw a face if and only if it is
        % a face of exactly one visible finite element.

        % Find all FEs whose vertexes are all visible.
        visFEs = all(visnodes(m.FEsets.fevxs),2);

        if ~any(visFEs)
            return;
        end

        % Find all the faces of those FEs.
        localfaces = m.FEsets.fe.faces;
        visFEvxs = [ zeros(sum(visFEs),1), m.FEsets.fevxs(visFEs,:) ];
        allVisFaces = reshape(visFEvxs(:,localfaces'+1), [], size(localfaces,1) );
        allVisFaceFEs = repmat( find(visFEs), size(localfaces,2), 1 );
        allVisFaceFaces = repmat( (1:size(localfaces,2))', sum(visFEs), 1 );

        allVisFaceIndexes = reshape( m.FEconnectivity.fefaces(visFEs,:), [], 1 );

        % Reindex them to the array of visible nodes.
        renumberToVisVxs = zeros( length(visnodes), 1 );
        renumberToVisVxs( visnodes ) = 1:sum(visnodes);
        renumberToVisVxs = [ 0; renumberToVisVxs ];
        allVisFaces = renumberToVisVxs( allVisFaces+1 );

        % Find all repeated faces and remove them.
        allVisFacesSorted = [ sort( allVisFaces, 2 ), repmat( find(visFEs), size(localfaces,2), 1 ) ];
        [allVisFacesSorted,perm] = sortrows( allVisFacesSorted );
        allVisFaces = allVisFaces(perm,:);
        allVisFaceIndexes = allVisFaceIndexes(perm,:);
        allVisFaceFEs = allVisFaceFEs(perm,:);
        allVisFaceFaces = allVisFaceFaces(perm,:);
        faceFEs = allVisFacesSorted(:,end);
        repeats = all( allVisFacesSorted(1:(end-1),1:(end-1))==allVisFacesSorted(2:end,1:(end-1)), 2 );
        repeats = [repeats;false] | [false;repeats];
        allVisFaces = allVisFaces(~repeats,:);
        allVisFaceIndexes = allVisFaceIndexes(~repeats,:);
        allVisFaceFEs = allVisFaceFEs(~repeats,:);
        allVisFaceFaces = allVisFaceFaces(~repeats,:);
        faceFEs = faceFEs(~repeats);
    %     usedFEvxs = renumberToVisVxs( m.FEsets.fevxs( faceFEs, : ) );
        % Each row of allVisFaces is a subset of the same row of usedFEvxs,
        % with one vertex left over.  We want to order the vertexes in
        % allVisFaces so that their right-handed normal points away from that
        % other vertex.  To do this without having to calculate FE volumes, we
        % need to know the local indexes of the vertexes
        flip = m.FEsets.fevolumes(faceFEs) < 0;
        allVisFaces(flip,:) = allVisFaces(flip,[1 (end:-1:2)]);

        if s.color
            if isempty(colors)
                if isPerVertex
                    colors = ones(sum(visnodes),3);
                else
                    colors = ones(length(faceFEs),3);
                end
            else
                if isPerVertex
                    colors = colors(visnodes,:);
                else
                    colors = colors(faceFEs,:);
                end
            end
        end

        g = Geometry( 'vxs', m.FEnodes(visnodes,:), ...
                      'facevxs', allVisFaces-1, ...
                      'color', colors, ...
                      'alpha', m.plotdefaults.alpha, ...
                      'facealpha', zeros(size(allVisFaces,1),1,'int32') );
    end
    g.plotoptions.drawedges = m.plotdefaults.drawedges;
    if s.color
        colorindex = int32(0:(length(colors)-1))';
        if isPerVertex
            g.vxcolor = colorindex;
%             g.facevxcolor = g.vxcolor( g.facevxs+1 );
        else
            g.facecolor = colorindex;
%             g.facevxcolor = repmat( g.facecolor, 1, size( g.facevxs, 2 ) );
        end
    end
    
    if s.optimisation >= 1
        removeUnused( g );
    end
    if s.optimisation >= 2
        uniquefy( g );
    end
    
    % Possibly we should also return 
end

function [v,renumber,varargout] = removeUnusedIndexes( v, varargin )
%[v,renumber,varargout] = removeUnusedIndexes( v, varargin )
%   V is an array and the variable arguments are all arrays of indexes into
%   the first dimension of V.  Find out which indexes are actually used.
%   Discard all unused rows of V and renumber the contents of all the other
%   arguments accordingly.  The indexing arrays are assumed to be
%   zero-indexed.

    used = cell(1,length(varargin));
    nonempty = false(1,length(varargin));
    for i=1:length(varargin)
        used{i} = unique(varargin{i})';
        nonempty(i) = ~isempty(used{i});
    end
    used = unique(cell2mat(used(nonempty)));
    renumber = zeros(size(v,1),1,'int32');
    renumber(used+1) = (1:length(used))';
    v = v(used+1,:);
    varargout = cell(1,length(varargin));
    for i=1:length(varargin)
        varargout{i} = renumber( varargin{i}+1 )-1;
    end
end
