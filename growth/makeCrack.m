function [m,splitVxs] = makeCrack( m, candidateVertexes, candidateFaces )
%m = makeCrack( m, candidateVertexes, candidateFaces )
%   Make a crack in the mesh along the given set of vertexes and faces.
%   For volumetric meshes only.
%   candidateVertexes is a set of vertexes to potentially split.
%   candidateFaces is a set of faces to potentially split.
%   The union of these will be taken.

    if nargin < 3
        candidateFaces = [];
    end
    splitVxs = [];

    if islogical( candidateVertexes )
        candidateVertexMap = candidateVertexes(:);
    else
        candidateVertexMap = false( getNumberOfVertexes(m), 1 );
        candidateVertexMap( candidateVertexes(:) ) = true;
    end

    if islogical( candidateFaces )
        candidateFaceMap = candidateFaces(:);
    else
        candidateFaceMap = false( getNumberOfFaces(m), 1 );
        candidateFaceMap( candidateFaces(:) ) = true;
    end
    
    morevertexes = unique( m.FEconnectivity.faces( candidateFaceMap, : ) );
    candidateVertexMap( morevertexes ) = true;

% Find the set of triangles among these vertexes. Discard any vertexes not part of any such triangle.
    candidateFaceVxs = candidateVertexMap( m.FEconnectivity.faces );
    candidateFaces = all( candidateFaceVxs, 2 );
    candidateFaceMap = false( size( m.FEconnectivity.faces, 1 ), 1 );
    candidateFaceMap( candidateFaces ) = true;
    
    candidateVertexList = unique( m.FEconnectivity.faces( candidateFaces, : ) );

% Consider each vertex that might be split. The set of splitting triangles that it belongs to
% must divide its neighbourhood into at least two disconnected components. There will be one copy of
% the vertex for each component. Each element will get the copy for the component it belongs to.

    [vxfes,~] = invertIndexArray( m.FEsets.fevxs, getNumberOfVertexes(m), 'cell' );
    vxfes = vxfes(candidateVertexList);
    [vxfaces,~] = invertIndexArray( m.FEconnectivity.faces, getNumberOfVertexes(m), 'cell' );
    vxfaces = vxfaces(candidateVertexList);
%     candidateFaceMap = false( size( m.FEconnectivity.edgeends, 1 ), 1 );
%     candidateFaceMap( cell2mat( vxfaces' ) ) = true;
    
    % For each vertex we now have its list of elements and list of faces.
    % From this we must construct the adjacency relationship among the
    % elements.
    
    realSplits = false( length(candidateVertexList), 1 );
    numrealsplits = 0;
    vxcpts = cell( length(candidateVertexList), 1 );
    totcpts = 0;
    for i=1:length(candidateVertexList)
        vi = candidateVertexList(i);
        fes = vxfes{i};
        numvxfes = length(fes);
        fefaces = m.FEconnectivity.fefaces( fes, : );
        aa = [ fefaces, fes(:) ];
        facefes = aa( :, [1 5 2 5 3 5 4 5] );
        facefes = reshape( facefes', 2, [] )';
        % Each row of facefes is a pair [F,E] consisting of a face and an element it
        % belongs to.
        
        % Discard entries for faces that do not include vi.
        keepfaces = any( m.FEconnectivity.faces( facefes(:,1), : )==vi, 2 );
        % ERROR: in testing we find that keepfaces is all true. But it
        % should be false for the faces of the elements that to not include
        % vi.
        facefes( ~keepfaces, : ) = [];
        % facefes now represents the adjacency graph.
        % We need to remove candidate splitting faces from this.
        facefes( candidateFaceMap( facefes(:,1) ), : ) = [];
        % ERROR: For the first vertex considered,
        % candidateFaceMap( facefes(:,1) ) true for 4 faces. But as far as
        % I can see, all of the candidate vertexes have 1, 2, 3, or 6
        % candidate faces.
        
        % Now we want to turn this representation of the adjacency graph
        % into one consisting of pairs of fes.
        facefes = sortrows( facefes );
        repeatedfaces = facefes(1:(end-1),1)==facefes(2:end,1);
        fepairs = [ [ facefes(repeatedfaces,2) facefes([false;repeatedfaces],2) ]; ...
                    repmat( fes, 1, 2 ) ];
        
        % Reindex the fes from 1 to N.
        [uf,~,ic] = unique( fepairs(:) );
        ufepairs = reshape( ic, size(fepairs) );
        
        % Use Matlab library functions to find connected components.
        g = graph( ufepairs(:,1), ufepairs(:,2) );
        cpts = conncomp(g);
        
        if max(cpts) > 1
            % This vertex is to be split.
            numrealsplits = numrealsplits+1;
            realSplits(i) = true;
            vxcpts{numrealsplits} = sortrows( [cpts(:),uf] );
            totcpts = totcpts + max(cpts);
        end
    end
    if numrealsplits==0
        xxxx = 1;
        return;
    end
    candidateVertexList = candidateVertexList(realSplits);
    vxcpts((numrealsplits+1):end) = [];
    
    % candidateVertexList is now a list of the vertexes that are to be
    % split. vxcpts lists for each vertex the components that the elements
    % neighbouring that vertex belongs to.
    
    % Each vertex in candidateVertexList must now be split into one vertex
    % for each component. The original vertex will be used for the first
    % component.
    
    numnewvxs = totcpts - length( candidateVertexList );
    numvxs = getNumberOfVertexes(m);
    currentNumvxs = numvxs;
    newvxsused = 0;
    reindexVxs = (1:(numvxs+numnewvxs))';
    for i=1:length(candidateVertexList)
        vi = candidateVertexList(i);
        vxcpt = vxcpts{i};
        [starts,ends] = runends( vxcpt(:,1) );
        newNumvxs = currentNumvxs+length(starts)-1;
        reindexVxs( (currentNumvxs+1):newNumvxs ) = vi;
        currentNumvxs = newNumvxs;
        for j=2:length(starts)
            newvxsused = newvxsused+1;
            fes = vxcpt( starts(j):ends(j), 2 );
            fevxs = m.FEsets(1).fevxs(fes,:);
            fevxs(fevxs==vi) = numvxs + newvxsused;
            m.FEsets(1).fevxs(fes,:) = fevxs;
        end
    end
    
    splitVxs = [ candidateVertexList; ((numvxs+1):(numvxs+numnewvxs))' ];
    
%     m.FEnodes = m.FEnodes( reindexVxs, : );
    m = replicateVxs( m, reindexVxs );
    
    % We have now updated the vertexes and elements, and all per-vertex
    % information.
    
    % Update the connectivity.
    m.FEconnectivity = connectivity3D( m );
    
    ok = validmesh( m )
    xxxx = 1;
end

function m = replicateVxs( m, vxlist )
%m = replicateVxs( m, ... )

    global gFIELDTYPES
    % gFIELDTYPES holds data on the types of the various array fields of m.
    
    for i=1:size(gFIELDTYPES,1)
        fn = gFIELDTYPES{i,1};
        % fn is the name of a deep field of m. If it is absent or empty, do
        % nothing.
        
        if strcmp( fn, 'visible.nodes' )
            xxxx = 1;
        end
        
        v = getDeepField( m, fn );
        if isempty( v )
%             fprintf( 1, 'Deep field %s not found.\n', fn );
            continue;
        end
        
        dimtypes = gFIELDTYPES{i,2};
        % dimtypes lists the types of the dimensions of the array.
        if ischar( dimtypes )
            dimtypes = { dimtypes };
        end
        
        vdims = length(size(v));
        changed = false;
        
        % Reindex every applicable dimension.
        for j=1:length(dimtypes)
            dimtype = dimtypes{j};
            if strcmp(dimtype,'prismvx')
                dimtype = 'fevx';
            end
            if ~strcmp(dimtype,'fevx')
                continue;
            end
            changed = true;
            whichcase = j+10*vdims;
            switch whichcase
                case 11
                    v = reshape( v(vxlist), [], 1 );
                case 21
                    v = v(vxlist,:);
                case 22
                    v = v(:,vxlist);
                case 31
                    v = v(vxlist,:,:);
                case 32
                    v = v(:,vxlist,:);
                case 33
                    v = v(:,:,vxlist);
                otherwise
                    % Not handled.
                    error( '%s: unexpected case %d.', mfilename(), whichcase );
            end
        end
        
        % Install updated version.
        if changed
            m = setDeepField( m, v, fn );
        end
    end
end

