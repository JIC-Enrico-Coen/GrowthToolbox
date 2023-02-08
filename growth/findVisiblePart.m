function m = findVisiblePart( m )
%m = findVisiblePart( m )
%   Set m.visible to a structure having the fields 'nodes', 'edges',
%   'cells', 'borderedges', and 'bordercells'.  Each of the first four is a
%   boolean array. The first three indicate which of the respective objects
%   are visible, and the fourth defines the set of edges bordering the
%   visible region.  The 'bordercells' field is a column vector of cell
%   indexes, listing the visible cell index bordering each border edge.
%   This is used to implement clipping in leaf_plot and writemeshvrml.

    full3d = usesNewFEs( m );
    if full3d
        nodes = m.FEnodes;
    else
        nodes = m.nodes;
    end

    clipmgens = m.plotdefaults.clipmgens;

    % Find the vertexes in the visible region.
    if m.plotdefaults.doclip
        clippingDirection = azel2dir( m.plotdefaults.clippingAzimuth, ...
                                      m.plotdefaults.clippingElevation );
        clipDistances = nodes * clippingDirection(:);
        visnodemap = (clipDistances >= m.plotdefaults.clippingDistance) ...
                     & ((m.plotdefaults.clippingThickness==Inf) | (clipDistances <= m.plotdefaults.clippingDistance + m.plotdefaults.clippingThickness));
    else
        visnodemap = true( size(nodes,1), 1 );
    end
    if m.plotdefaults.clipbymgen && ~isempty(clipmgens)
        if iscell( clipmgens )
            cm = zeros(1,length(clipmgens));
            for i=1:length(clipmgens)
                try
                    cm(i) = m.mgenNameToIndex.(clipmgens{i});
                catch e %#ok<NASGU>
                end
            end
            clipmgens = cm(cm ~= 0);
        end
        if ~isempty(clipmgens)
            if m.plotdefaults.clipmgenabove
                clipmgenvals = m.morphogens(:,clipmgens) < m.plotdefaults.clipmgenthreshold;
            else
                clipmgenvals = m.morphogens(:,clipmgens) > m.plotdefaults.clipmgenthreshold;
            end
            if m.plotdefaults.clipmgenall
                mgenclipped = prod( double(clipmgenvals), 2 ) > 0;
            else
                mgenclipped = sum( double(clipmgenvals), 2 ) > 0;
            end
            visnodemap = visnodemap & ~mgenclipped;
        end
    end

    if full3d
        % An element is in the visible part of the mesh if all its vertexes are.
        viselementmap = all( reshape( visnodemap( m.FEsets(1).fevxs ), size(m.FEsets(1).fevxs) ), 2 );
        
        % A face is in the visible part if it is a face of at least one visible element.
        % A face is surface-visible if it is a face of exactly one visible element.
        visfaceindexes = sort( reshape( m.FEconnectivity.fefaces( viselementmap, : ), [], 1 ) );
        surfvisfaceindexes = visfaceindexes;
        repeated = visfaceindexes(1:(end-1))==visfaceindexes(2:end);
        multiplefaces = [repeated; false] | [false; repeated];
        visfaceindexes( repeated ) = [];
        surfvisfaceindexes( multiplefaces ) = [];
        visfacemap = false( size(m.FEconnectivity.faces, 1 ), 1 );
        visfacemap( visfaceindexes ) = true;
        surfvisfacemap = false( size(m.FEconnectivity.faces, 1 ), 1 );
        surfvisfacemap( surfvisfaceindexes ) = true;
        
        % An element is a surface element if it has a visible face.
        exteriorelements = any( surfvisfacemap( m.FEconnectivity.fefaces( viselementmap, : ) ), 2 );
        surfviselementindexes = find( viselementmap );
        surfviselementindexes( ~exteriorelements ) = [];
        surfviselementmap = false( size(m.FEsets(1).fevxs, 1 ), 1 );
        surfviselementmap( surfviselementindexes ) = true;
        
        % An edge is visible if it is an edge of a visible face.
        visedges = unique( m.FEconnectivity.faceedges( visfacemap, : ) );
        if ~isempty(visedges) && (visedges(1)==0)
            visedges(1) = [];
        end
        visedgemap = false( size(m.FEconnectivity.edgeends, 1 ), 1 );
        visedgemap(visedges) = true;

        % An edge is a surface edge if it is an edge of a surface face.
        surfvisedges = unique( m.FEconnectivity.faceedges( surfvisfacemap, : ) );
        if ~isempty(surfvisedges) && surfvisedges(1)==0
            surfvisedges(1) = [];
        end
        surfvisedgemap = false( size(m.FEconnectivity.edgeends, 1 ), 1 );
        surfvisedgemap(surfvisedges) = true;
        
        % A vertex is a surface vertex if it is a vertex of a surface edge.
        surfvisnodeindexes = unique( m.FEconnectivity.edgeends( surfvisedgemap, : ) );
        surfvisnodemap = false( size( m.FEnodes, 1 ), 1 );
        surfvisnodemap(surfvisnodeindexes) = true;
        
        m.visible = struct( ...
            'nodes', visnodemap, ...
            'edges', visedgemap, ...
            'faces', visfacemap, ...
            'elements', viselementmap, ...
            'surfnodes', surfvisnodemap, ...
            'surfedges', surfvisedgemap, ...
            'surffaces', surfvisfacemap, ...
            'surfelements', surfviselementmap );
    else
        if size(m.tricellvxs,1)==1  % Workaround for MATLAB quirk.
            viscells = all( visnodemap(m.tricellvxs) );
        else
            viscells = all( visnodemap(m.tricellvxs), 2 );
        end
        visedgecells = viscells(m.edgecells(:,1));
        visedgecells(:,2) = false;
        ex2 = m.edgecells(:,2) ~= 0;
        visedgecells(ex2,2) = viscells(m.edgecells(ex2,2));
        visedges = any( visedgecells, 2 );
        borderedges = visedgecells(:,1) ~= visedgecells(:,2);
        bordercellpairs = m.edgecells(borderedges,:);
        secondcellvis = visedgecells(borderedges,2);
        bordercells = bordercellpairs(:,1);
        bordercells(secondcellvis) = bordercellpairs(secondcellvis,2);
        bordernodes = false( size(nodes,1), 1 );
        bordernodes( unique( m.edgeends( borderedges, : ) ) ) = true;
        m.visible = struct( ...
            'nodes', visnodemap, ...
            'cells', viscells, ...
            'edges', visedges, ...
            'bordernodes', bordernodes, ...
            'borderedges', borderedges, ...
            'bordercells', bordercells );
    end
end
