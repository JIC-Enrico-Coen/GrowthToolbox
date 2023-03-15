function [m,splitVertexList,reindexVxs] = makeCrack( m, candidateVertexes, candidateFaces )
%m = makeCrack( m, candidateVertexes, candidateFaces )
%   Make a crack in the mesh along the given set of vertexes and faces.
%   For volumetric meshes only.
%   candidateVertexes is a set of vertexes to potentially split.
%   candidateFaces is a set of faces to potentially split.
%   The union of these will be taken.
%
%   splitVxs is a list of all the vertexes of the old mesh that were split.
%
%   reindexVxs maps each vertex index of the new mesh to its parent vertex
%   index in the old mesh.

% The only use we currently make of this procedure is with
% candidateVertexes empty  and candidateFaces being a set of faces to
% possibly split.

    if nargin < 3
        candidateFaces = [];
    end

    % Convert the arguments to boolean maps.
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
    
    splitVertexList = [];
    reindexVxs = (1:getNumberOfVertexes(m))';
    
    timedFprintf( 'Initially %d candidate faces, %d candidate vertexes.\n', sum(candidateFaceMap), sum(candidateVertexMap) );
    
    if ~any( candidateVertexMap ) && ~any( candidateFaceMap )
        timedFprintf( 'No splitting candidates supplied.\n' );
        return;
    end
    
    candidateNormals1 = checkCandidateFaceNormals( m, candidateFaceMap );
    
    % All vertexes of candidate faces are also candidate vertexes.
%     morevertexes = unique( m.FEconnectivity.faces( candidateFaceMap, : ) );
%     candidateVertexMap( morevertexes ) = true;

% % Find the set of faces, all of whose vertexes are candidate vertexes.
% % These are now the candidate faces.
%     candidateFaceVxs = candidateVertexMap( m.FEconnectivity.faces );
%     candidateFaces = all( candidateFaceVxs, 2 );
%     candidateFaceMap = false( size( m.FEconnectivity.faces, 1 ), 1 );
%     candidateFaceMap( candidateFaces ) = true;
% Any vertexes not part of any candidate face are no longer candidate vertexes.
    candidateVertexList = unique( m.FEconnectivity.faces( candidateFaces, : ) );

    timedFprintf( 'Now %d candidate faces, %d candidate vertexes.\n', sum(candidateFaceMap), length(candidateVertexList) );
    
% Consider each vertex that might be split. The set of splitting triangles that it belongs to
% must divide its neighbourhood into at least two disconnected components. There will be one copy of
% the vertex for each component. Each element will get the copy for the component it belongs to.

    [vxfes,~] = invertIndexArray( m.FEsets.fevxs, getNumberOfVertexes(m), 'cell' );
    vxfes = vxfes(candidateVertexList);
    
    candidateNormals2 = checkCandidateFaceNormals( m, candidateFaceMap );
    
    timedFprintf( 'Now %d candidate faces, %d candidate vertexes.\n', sum(candidateFaceMap), length(candidateVertexList) );
    
    % For each vertex we now have its list of elements and list of faces.
    % From this we must construct the adjacency relationship among the
    % elements.
    
    realSplits = false( length(candidateVertexList), 1 );
    numrealsplits = 0;
    vxFEcpts = cell( length(candidateVertexList), 1 );
    totcpts = 0;
    for cVLi=1:length(candidateVertexList)
        vi = candidateVertexList(cVLi);
        fes = vxfes{cVLi};
        fefaces = m.FEconnectivity.fefaces( fes, : );
        aa = [ fefaces, fes(:) ];
        facefes = aa( :, [1 5 2 5 3 5 4 5] );
        facefes = reshape( facefes', 2, [] )';
        % Each row of facefes is a pair [F,E] consisting of a face and an element it
        % belongs to.
        
        % Discard entries for faces that do not include vi.
        keepfaces = any( m.FEconnectivity.faces( facefes(:,1), : )==vi, 2 );
        
        % Check: the number of faces discarded should equal the number of
        % fes this vertex belongs to.
        ok = length(keepfaces) - sum(keepfaces) == length(fes);
        
        facefes( ~keepfaces, : ) = [];
        % facefes now represents the adjacency graph.
        % We need to remove candidate splitting faces from this.
        facefes( candidateFaceMap( facefes(:,1) ), : ) = [];
        % ERROR: For the first vertex considered,
        % candidateFaceMap( facefes(:,1) ) is true for 4 faces. But as far
        % as I can see, all of the candidate vertexes have 1, 2, 3, or 6
        % candidate faces.
        
        % Now we want to turn this representation of the adjacency graph
        % into one consisting of pairs of fes.
        facefes = sortrows( facefes );
        % Faces that lie on the surface are part of just one element, and
        % therefore do not represent connections between elements.
        repeatedfaces = facefes(1:(end-1),1)==facefes(2:end,1);
        fepairs1 = [ facefes(repeatedfaces,2) facefes([false;repeatedfaces],2) ];
        fepairs = [ fepairs1; repmat( fes, 1, 2 ) ];
        
        % Reindex the fes from 1 to N.
        [uf,~,ic] = unique( fepairs(:) );
        ufepairs = reshape( ic, size(fepairs) );
        [uf1,~,ic1] = unique( fepairs1(:) );
        ufepairs1 = reshape( ic1, size(fepairs1) );
        if length(uf1) ~= length(uf)
            xxxx = 1;
        end
        
        % Use Matlab library functions to find connected components.
        g = graph( ufepairs(:,1), ufepairs(:,2) );
        cpts = conncomp(g);
        g1 = graph( ufepairs1(:,1), ufepairs1(:,2) );
        cpts1 = conncomp(g1);
        numcpts = max(cpts);
        
        if numcpts > 1
            % This vertex is to be split into as many copies as there are
            % components.
            numrealsplits = numrealsplits+1;
            realSplits(cVLi) = true;
            vxFEcpts{numrealsplits} = sortrows( [cpts(:),uf] );
            totcpts = totcpts + numcpts;
            
            timedFprintf( 'Vertex %d splits into %d copies.\n', cVLi, numcpts );
            
            % For checking purposes, we want to find the faces that join
            % components. These are the faces that were actually split.
%             cptpairs = cpts( ufepairs );
%             joiningufaces = cptpairs(:,1) ~= cptpairs(:,2);
%             joiningfaces = uf( joiningufaces );
            
            xxxx = 1;
        end
    end
    if numrealsplits==0
        % No vertexes were split.
        timedFprintf( 'No vertexes were split.\n' );
        return;
    end
    splitVertexList = candidateVertexList(realSplits);
    vxFEcpts((numrealsplits+1):end) = [];
    
    % splitVertexList is a list of the vertexes that are to be
    % split. vxcpts lists for each vertex the components that the elements
    % neighbouring that vertex belongs to.
    
    % Each vertex in splitVertexList must now be split into one vertex
    % for each component. The original vertex will be used for the first
    % component.
    
    numnewvxs = totcpts - length( splitVertexList );
    numvxs = getNumberOfVertexes(m);
    currentNumvxs = numvxs;
    newvxsused = 0;
    reindexVxs = (1:(numvxs+numnewvxs))';
    for sVLi=1:length(splitVertexList)
        vi = splitVertexList(sVLi);
        vxcpt = vxFEcpts{sVLi};
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
    
%     m.FEnodes = m.FEnodes( reindexVxs, : );
    m = replicateVxs( m, reindexVxs );
    if isfield( m.auxdata, 'vxringindexes' )
        m.auxdata.vxringindexes = m.auxdata.vxringindexes(reindexVxs);
    end
    
    % We have now updated the vertexes and elements, and all per-vertex
    % information.
    
    % Update the connectivity.
    m.FEconnectivity = connectivity3D( m );
    
    ok = validmesh( m );
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
        
        v = getDeepField( m, fn );
        if isempty( v )
%             fprintf( 1, 'Deep field %s not found.\n', fn );
            continue;
        end
        
        if strcmp( fn, 'globalDynamicProps.stitchDFsets' )
            % Special case handling.
            % m.globalDynamicProps.stitchDFsets is a cell array of an
            % arbitrary length, each element of which is a list of vertex
            % degree of freedom indexes.
            oldnumvxs = max(vxlist);
            v1 = cell(size(v));
            for si=1:numel(v)
                % v1{si} should be set to the set of all new vertex
                % indexes that are mapped by vxlist to members of
                % v{si}.
                fixedvxs = floor((v{si}-1)/3)+1;
                fixeddfs = mod( v{si}-1, 3 ) + 1;
                
                fixedvxsmap = false( oldnumvxs, 1 );
                fixedvxsmap( fixedvxs ) = true;
                
                fixeddfsmap = zeros( oldnumvxs, 1 );
                fixeddfsmap( fixedvxs ) = fixeddfs;
                
                newfixedvxsmap = fixedvxsmap( vxlist );
                newfixedvxs = find( newfixedvxsmap );
                
                newfixeddfsmap = fixeddfsmap( vxlist );
                newfixeddfs = newfixeddfsmap( newfixedvxsmap );
                
                v1{si} = 3*(newfixedvxs - 1) + newfixeddfs;
            end
            v = v1;
        else
        
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
        end
        
        % Install updated version.
        if changed
            m = setDeepField( m, v, fn );
        end
    end
end

function a = replicateValues( a, vxlist )
    
end

function fns = checkCandidateFaceNormals( m, faces )
    fns = mesh3DFaceNormals( m, faces );
    anglesToHoriz = atan2( sqrt(sum(fns(:,[1 2]).^2,2)), abs(fns(:,3)) ) * (180/pi);
    timedFprintf( 'Breaking face angle to horizontal %.2f to %.2f degrees.\n', min(anglesToHoriz), max(anglesToHoriz) );
    xxxx = 1;
end
