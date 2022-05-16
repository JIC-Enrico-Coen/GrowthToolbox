function c = connectivity3D( m )
% c = connectivity3D( m )
%   Given a mesh whose geometry is described by m.FEnodes and m.FEsets, and
%   these alone, calculate the following connectivity information.  Let L
%   be the number of finite elements, F the number of faces, E the number
%   of edges, and V the number of vertexes.
%
%         ... % Per-FE data.
%         'allfevxs', allfevxs, ...
%         'nzallfevxs', nzallfevxs, ...
%         'numfevxs', numfevxs, ...
%         'fetypes', fetypes, ...
%         'feedges', feedges, ...
%         'fefaces', fefaces, ...
%         ...
%         ... % Per-face data.
%         'faces', faces, ...
%         'numfacevxs', numfacevxs, ...
%         'faceedges', faceedges, ...
%         'facefes', facefes, ...
%         'facefefaces', facefefaces, ...
%         'faceloctype', faceloctype, ...
%         ...
%         ... % Per-edge data
%         'edgeends', edgeends, ...
%         'edgefaces', edgefaces, ...
%         'edgeloctype', edgeloctype, ...
%         ...
%         ... % Per-vertex data
%         'vertexloctype', vertexloctype );
%
%   Per-element data:
%
%   allfevxs: An L*ANY ragged array listing the vertexes of every element.
%       (Not needed -- this duplicates m.FEsets.fevxs when there is only
%       one set of FEs. Used only in computeResiduals and testVFEN.))
%   nzallfevxs: A boolean map of the nonzero elements of allfevxs. (Also
%       not needed.  Never used.)
%   numfevxs: An L*1 array listing the number of vertexes for each FE.
%   fetypes: An L*1 array listing the type of each FE, i.e. which element
%       of m.FEsets describes it.
%   feedges: An L*ANY ragged array with one row for every FE, listing all of its
%       edges in the same order as they are represented internally to the
%       FE.  (This will only be ragged if there are multiple FE sets.)
%   fefaces: An L*ANY ragged array with one row for every FE, listing all of its
%       faces in the same order as they are represented internally to the
%       FE.  (This will only be ragged if there are multiple FE sets.)
%
%   Per-face data:
%
%   faces: An F*K array with one row for every face.  K is the maximum
%       number of vertexes of any face in the mesh.  In practice K is
%       always 3 or 4. The ordering of vertexes is consecutive around the
%       face. It may start at any vertex and go in either direction.  If a
%       face has fewer than the maximum number of vertexes then the missing
%       values are represented as 0 and stored at the end of the row.
%   numfacevxs: An F*1 array listing the number of vertexes for each face.
%   faceedges: An F*ANY ragged array listing the edges of each face.
%   facefes: An F*2 array mapping each face to the elements on either side.
%       If a face has an element on only one side, the second index is
%       zero.
%   facefefaces: An F*2 array mapping each face to its index with respect
%       to the elements on either side. If a face has an element on only
%       one side, the second index is zero.
%   faceloctype: An F*1 array classifying each face as interior (0) or
%       surface (1).
%   facefeparity: An F*2 array of booleans, corresponding to facefes. For
%       each face and each fe the face belongs to, it says whether the
%       ordering of vertexes fo the face in connectivity.faces is the same
%       as the ordering of its vertexes in the finite element. Where
%       facefes is zero, faceparity is false.
%
%   Per-edge data:
%
%   edgeends: An E*2 array with one row for every pair of vertexes
%       connected by an edge.  The lower vertex index always comes first.
%   edgefaces: An E*ANY ragged array mapping each edge to the list of faces
%       it belongs to.
%   edgeloctype: An E*1 array classifying each edge as interior (0),
%       surface (1), or corner (2).
%   edgeFEs: An N*K array with one row for every edge.  Each row lists the
%       finite elements that that edge is an edge of.  Unused elements of
%       the row are zero.
%
%   Per-vertex data
%
%   vertexloctype: A V*1 array classifying each vertex as interior (0),
%       surface (1), edge(2), or corner (3).
%
%   Topics: volumetric mesh

fprintf( 2, '%s called\n', mfilename() );

    numAllFEs = 0;
    maxVxsPerFE = 0;
    maxVxsPerFEFace = 0;
    numsets = length(m.FEsets);
    
    for i=1:numsets
        numAllFEs = numAllFEs + size( m.FEsets(i).fevxs, 1 );
        maxVxsPerFE = max( maxVxsPerFE, size( m.FEsets(i).fe.canonicalVertexes, 1 ) );
        maxVxsPerFEFace = max( maxVxsPerFEFace, size( m.FEsets(i).fe.faces, 1 ) );
    end
    
    allfevxs = zeros( numAllFEs, maxVxsPerFE );
    fetypes = zeros( numAllFEs, 1 );
    numallfevxs = 0;
    
    faces = cell(numsets,1);
    edgeends = cell(numsets,1);
    fefaces = cell(numsets,1);
    numFEsSoFar = 0;
    
    for i=1:numsets
        fetype = m.FEsets(i).fe;
        numFEs = size( m.FEsets(i).fevxs, 1 );
        numVxs = size( fetype.canonicalVertexes, 1 );
        
        allfevxs( (numallfevxs+1):(numallfevxs+numFEs), 1:numVxs ) = m.FEsets(i).fevxs;
        fetypes( (numallfevxs+1):(numallfevxs+numFEs) ) = i;
        numallfevxs = numallfevxs + numFEs;
        
        typeedges = fetype.edges(:);
        edgelist = reshape( permute( reshape( m.FEsets(i).fevxs(:,typeedges), size(m.FEsets(i).fevxs,1), 2, [] ), [2 1 3] ), 2, [] );
        edgelist = unique( sort( edgelist, 1 )', 'rows' );
        edgeends{i} = edgelist;
        typefaces = fetype.faces';
        facearraysize = size( fetype.faces );
        facesPerFE = facearraysize(2);
        maxVxsPerFace = facearraysize(1);
        facelist = zeros( facesPerFE*size(m.FEsets(i).fevxs,1), maxVxsPerFace+2 );
        faceedgelist = zeros( size(m.FEsets(i).fevxs,1), maxVxsPerFace );
        feindexes = ((numFEsSoFar+1):(numFEsSoFar+numFEs))';
        for j=1:facesPerFE
            nz = find( typefaces(j,:)>0, 1, 'last' );
            typeface = typefaces(j,1:nz);
            facelist((j-1)*numFEs + (1:numFEs),1:(maxVxsPerFace+2)) = [ nz+zeros(numFEs,1), m.FEsets(i).fevxs(:,typeface), zeros(numFEs,maxVxsPerFace-nz), feindexes ];
            faceedgelist((j-1)*numFEs + (1:numFEs),1:(nz+1)) = [ nz+zeros(numFEs,1), m.FEsets(i).fevxs(:,typeface) ];
        end
        faces{i} = facelist;
        fefacelist = reshape( (1:size(facelist,1))', numFEs, facesPerFE );
        fefaces{i} = fefacelist;
        numFEsSoFar = numFEsSoFar + numFEs;
    end
    faces = cell2mat(faces);
    edgeends = cell2mat(edgeends);
    fefaces = cell2mat(fefaces);
    
    nzallfevxs = allfevxs > 0;
    numfevxs = sum( nzallfevxs, 2 );

    faces1 = sort( faces(:,2:(end-1)), 2 );
    [faces1,faceperm] = sortrows( faces1 );
    faces = faces(faceperm,:);
    invfaceperm(faceperm) = 1:length(faceperm);
    [~,selected,zz] = unique( faces1, 'rows', 'first' );
    fefaces = zz(invfaceperm(fefaces));
    isuniqueface = zeros( size(faces,1)+1, 1 );
    isuniqueface(selected) = 1;
    isuniqueface(end) = 1;
    isuniqueface = isuniqueface(1:(end-1),1) & isuniqueface(2:end,1);
    faces = faces( selected, : );
    numfacevxs = faces(:,1);
    [facesizestarts,facesizeends,facesizes] = runends( numfacevxs );
    evenfacefes = faces(:,end);
    faces = faces(:,2:(end-1));
    faceloctype = isuniqueface(selected);
    % faceloctype is 0 for interior faces, 1 for exterior faces.
    % An exterior face is one that belongs to exactly one element.
    
    v2 = zeros(size(faces));
    for i=1:length(facesizestarts)
        s = facesizestarts(i);
        e = facesizeends(i);
        n = facesizes(i);
        v2(s:e,1:n) = faces(s:e,[2:n 1]);
    end
    v1 = min(faces,v2);
    v2 = max(faces,v2);
    [fe_edges,~,i2] = unique( [v1(:), v2(:)], 'rows' );
    if ~isempty(fe_edges) && (fe_edges(1,1)==0)
        fe_edges(1,:) = [];
        i2 = i2-1;
    end
    faceedges = reshape(i2,size(faces));

    % Check.
    for i=1:length(facesizestarts)
        s = facesizestarts(i);
        e = facesizeends(i);
        n = facesizes(i);
        ed = faceedges(s:e,1:n);
        v1a = reshape( fe_edges(ed,1), size(ed) );
        v2a = reshape( fe_edges(ed,2), size(ed) );
        v1x = v1(s:e,1:n);
        v2x = v2(s:e,1:n);
        if any(v1a(:) ~= v1x(:)) || any(v2a(:) ~= v2x(:))
            xxxx = 1;
        end
    end
    % FACEEDGES lists for each face, its edges, in the same order as the
    % vertexes are listed in FACES.
    
    allfeedges = cell(numsets,1);
    for i=1:numsets
        alledgeendsdata = m.FEsets(i).fevxs( :, m.FEsets(i).fe.edges' );
        alledgeendsdata = reshape( alledgeendsdata, size(m.FEsets(i).fevxs,1), size(m.FEsets(i).fe.edges,2), 2 );
        alledgeendsdata(:,:,3) = repmat( (1:size(alledgeendsdata,1))', 1, size(alledgeendsdata,2), 1 );
        alledgeendsdata = reshape( alledgeendsdata, [], 3 );
        allfeedges{i} = alledgeendsdata ;
    end
    allfeedges = cell2mat( allfeedges );
    xx = min(allfeedges(:,[1 2]), [], 2);
    yy = max(allfeedges(:,[1 2]), [], 2);
    allfeedges(:,[1 2]) = [xx yy];
    allfeedges = sortrows( allfeedges );
    [s,e] = runends( hash2ints( allfeedges(:,[1 2]), 'sym' ) );
    
    edgeedges = s==e;
    
    % An interior edge (edgeloctype==0) is one not belonging to any surface face.
    % Other edges are exterior.  These are of two types: those not on an
    % edge of the body (edgeloctype==1) and those on an edge
    % (edgeloctype==2).  The latter are detected by the fact that they
    % belong to exactly one element.
    edgeloctype = zeros( size(edgeends,1), 1 );
    noninterioredges = faceedges( faceloctype==1, : );
    noninterioredges = unique( noninterioredges );
    if ~isempty(noninterioredges) && (noninterioredges(1)==0)
        noninterioredges(1) = [];
    end
    edgeloctype(noninterioredges) = 1;
    edgeloctype(edgeedges) = 2;
    
    % Vertex locations are of four types:
    % 0: interior (they to not belong to any noninterior edge)
    % 1: interior of surface (not interior, but do not belong to any edge
    % edge).
    % 2: interior of edge (belong to exactly two edge edges).
    % 3: corner (belong to at least three edge edges).
    noninteriorvxs = edgeends(noninterioredges,:);
    noninteriorvxs = unique( noninteriorvxs );
    vertexloctype = zeros( size(m.FEnodes,1), 1 );
    vertexloctype( noninteriorvxs ) = 1;
    
    % An edge vertex is one belonging to an edge edge.
    eev = edgeends(edgeloctype == 2,:);
    eev = sort(eev(:));
    [s,e] = runends(eev);
    numreps = e-s+1;
    vertexloctype(eev(s)) = 2;
    % Corner vertexes are those belonging to at least 3 edge edges.
    vertexloctype(eev(s(numreps>=3))) = 3;
    
    % Perhaps edge edges should be those belonging to two exterior faces
    % whose surface normals are sufficiently different?
    
    % Need elementfaces, listing for each element all its faces.
    % Given that, we can determine which are the interior faces: those
    % belonging to more than one element.
    
    % An interior element is one having only interior faces.
    % A surface element is one having at least one surface face and no edge
    % edges.
    % An edge element is one having an edge element and no corner vertexes.
    % A corner element is one having at least one corner vertex.
    
    edgefaces = invertIndexArray( faceedges, [], 'array' );
    
    numedges = size(edgeends,1);
    reorder = edgeends(:,1) > edgeends(:,2);
    edgeends(reorder,:) = edgeends(reorder,[2 1]);
    edgeendsWithEdge = [ edgeends, zeros(numedges,1), (1:numedges)' ];
    feedgeends = m.FEsets(1).fe.edges;
    edgesperFE = size(feedgeends,2);
    feedgevxs = m.FEsets(1).fevxs(:,feedgeends);
    feedgevxs = reshape( feedgevxs, numFEs, 2, [] );
    feedgevxs(:,3,:) = reshape( repmat( (1:numFEs)', 1, edgesperFE ), numFEs, 1, edgesperFE );
    feedgevxs(:,4,:) = repmat( reshape( 1:edgesperFE, 1, 1, [] ), numFEs, 1, 1 );
    feedgevxs = reshape( permute( feedgevxs, [2 1 3] ), 4, [] )';
    
    
    reorder = feedgevxs(:,1) > feedgevxs(:,2);
    feedgevxs(reorder,[1 2]) = feedgevxs(reorder,[2 1]);

    alledgeendsdata = sortrows( [ edgeendsWithEdge; feedgevxs ] );
    if isempty(alledgeendsdata)
        feedges = zeros(0,edgesperFE);
    else
        for i=1:size(alledgeendsdata,1)
            if alledgeendsdata(i,3)==0
                curedge = alledgeendsdata(i,4);
            else
                alledgeendsdata(i,5) = curedge;
            end
        end
        alledgeendsdata(:,[1 2]) = [];
        alledgeendsdata(alledgeendsdata(:,3)==0,:) = [];
        alledgeendsdata = sortrows(alledgeendsdata);
        feedges = reshape( alledgeendsdata(:,3), edgesperFE, numFEs )';
    end
    
    numfes = size(fefaces,1);
    facesperfe = size(fefaces,2);
    foo = [ fefaces; repmat( (1:numfes)', 1, facesperfe ); repmat( 1:facesperfe, numfes, 1 ) ];
    foo = sortrows( reshape( reshape( foo, numfes, [] )', 3, [] )' );
    doubles = foo(1:(end-1),1)==foo(2:end,1);
    singles = ~([doubles;false] | [false;doubles]);
    facefedata = sortrows( [[foo(doubles,:), foo([false;doubles],[2 3])]; [foo(singles,:), zeros(sum(singles),2)]] );
    % Each row of facefedata has the form [ face, fe1, feface1, fe2 feface2 ].
    % face is equal to the index of the row.
    facefes = facefedata(:,[2 4]);
    facefefaces = facefedata(:,[3 5]);
    
    facefeparity = facefes(:,1)==evenfacefes;
    
    c = struct( ...
        ... % Per-FE data.
        'allfevxs', allfevxs, ...
        'nzallfevxs', nzallfevxs, ...
        'numfevxs', numfevxs, ...
        'fetypes', fetypes, ...
        'feedges', feedges, ...
        'fefaces', fefaces, ...
        ...
        ... % Per-face data.
        'faces', faces, ...
        'numfacevxs', numfacevxs, ...
        'faceedges', faceedges, ...
        'facefes', facefes, ...
        'facefeparity', facefeparity, ...
        'facefefaces', facefefaces, ...
        'faceloctype', faceloctype, ...
        ...
        ... % Per-edge data
        'edgeends', edgeends, ...
        'edgefaces', edgefaces, ...
        'edgeloctype', edgeloctype, ...
        ...
        ... % Per-vertex data
        'vertexloctype', vertexloctype );
end
