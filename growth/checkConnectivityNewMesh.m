function [ok,errs] = checkConnectivityNewMesh( m, verbose )
%[ok,errs] = checkConnectivityNewMesh( m )
%   Perform validity checks on the connectivity information for a mesh of
%   general FEs.

    if nargin < 2
        verbose = true;
    end

    ERRORS = false;
    if ERRORS
        complainer = @error;
    else
        complainer = @warning;
    end
    if verbose
        whiner = @warning;
    else
        whiner = @donothing;
    end

    ok = true;
%{
    m.FEconnectivity has the following fields:
    
     allfevxs: [40×4 double]
   nzallfevxs: [40×4 logical]
     numfevxs: [40×1 double]
      fetypes: [40×1 double]
      feedges: [40×6 double]
      fefaces: [40×4 double]
        faces: [104×3 double]
   numfacevxs: [104×1 double]
    faceedges: [104×3 double]
    edgefaces: [90×6 double]
  faceloctype: [104×1 logical]
     edgeends: [90×2 double]
  edgeloctype: [90×1 double]
vertexloctype: [27×1 double]
      facefes
  facefefaces
%}
    
    errs = 0;
    
    [ok1,errs] = checkBasicConnectivity3DMesh( m, verbose );
    ok = ok && ok1;

    numVxs = getNumberOfVertexes( m );
    numEdges = size( m.FEconnectivity.edgeends, 1 );
    numFaces = size( m.FEconnectivity.faces, 1 );
    numFEs = getNumberOfFEs( m );
    vxsPerFE = size( m.FEsets.fe.canonicalVertexes, 1 );
    edgesPerFE = size( m.FEsets.fe.edges, 2 );
    facesPerFE = size( m.FEsets.fe.faces, 2 );
    vxsPerFace = size( m.FEsets.fe.faces, 1 );
    edgesPerFace = vxsPerFace;
    c = m.FEconnectivity;

% Check the sizes of all components.
    checksize( 'allfevxs', [], numFEs, vxsPerFE );
    checksize( 'nzallfevxs', [], numFEs, vxsPerFE );
    checksize( 'numfevxs', [], numFEs, 1 );
    checksize( 'fetypes', [], numFEs, 1 );
    checksize( 'feedges', [], numFEs, edgesPerFE );
    checksize( 'fefaces', [], numFEs, facesPerFE );
    checksize( 'FEsets.fevxs', m.FEsets.fevxs, numFEs, 0 );

    
    checksize( 'faces', [], numFaces, vxsPerFace );
    checksize( 'numfacevxs', [], numFaces, 1 );
    checksize( 'faceedges', [], numFaces, edgesPerFace );
    checksize( 'faceloctype', [], numFaces, 1 );
    checksize( 'facefes', [], numFaces, 2 );
    checksize( 'facefefaces', [], numFaces, 2 );
    
    checksize( 'edgefaces', [], numEdges, 0 );
    checksize( 'edgeends', [], numEdges, 2 );
    checksize( 'edgeloctype', [], numEdges, 1 );
    
    checksize( 'vertexloctype', [], numVxs, 1 );
    
% Check that all values are in the proper range.
    checkvalues( 'allfevxs', [], numVxs, true );
    checkvalues( 'feedges', [], numEdges, true );
    checkvalues( 'fefaces', [], numFaces, true );
    checkvalues( 'faces', [], numVxs, true );
    checkvalues( 'faceedges', [], numEdges, true );
    checkvalues( 'edgefaces', [], numFaces, true );
    checkvalues( 'edgeends', [], numVxs, false );
    checkvalues( 'FEsets.fevxs', m.FEsets.fevxs, numVxs, false );

% Check consistency of faceedges, edgeends, and faces.
    zedges = c.faceedges==0;
    numedges1 = find( any(zedges,1) );
    hasNedges = false( size(c.faceedges,1), length(numedges1)+1 );
    for i=1:length(numedges1)
        hasNedges(:,i) = c.faceedges(:,numedges1(i))==0;
    end
    hasNedges(:,end) = c.faceedges(:,end) ~= 0;
    numedges = [ numedges1-1, size(c.faceedges,2) ];
    
    if numel(hasNedges) > 1
        for i=1:size(hasNedges,2)
            edgesPerFace = numedges(i);
            aa = c.faceedges(hasNedges(:,i),1:edgesPerFace);
            numFaces1 = size(aa,1);
            bb = c.edgeends( aa', : );
            cc = reshape( bb, edgesPerFace, numFaces1, 2 );
            dd = permute( cc, [2 1 3] );
            ee = reshape( dd, numFaces1, [] );
            x1 = sort( ee, 2 );
            if ~isempty(x1)
                if ~all(reshape(x1(:,1:2:end)==x1(:,2:2:end),[],1))
                    errs = errs+1;
                    complainer( 'faceedges->edgeends: vertexes do not occur in pairs' );
                end
                x1a = x1(:,1:2:end);
                x2 = sort( c.faces(hasNedges(:,i),1:edgesPerFace), 2 );
                if any(x1a(:) ~= x2(:))
                    errs = errs+1;
                    complainer( 'faceedges->edgeends is not consistent with faces' );
                end
            end
        end
    else
        aa = c.faceedges;
        bb = c.edgeends( aa', : );
        cc = reshape( bb, edgesPerFace, numFaces, 2 );
        dd = permute( cc, [2 1 3] );
        ee = reshape( dd, numFaces, [] );
        x1 = sort( ee, 2 );
        if ~isempty(x1)
            if ~all(reshape(x1(:,1:2:(vxsPerFace*2))==x1(:,2:2:(vxsPerFace*2)),[],1))
                errs = errs+1;
                complainer( 'faceedges->edgeends: vertexes do not occur in pairs' );
            end
            x1 = x1(:,1:2:(vxsPerFace*2));
            x2 = sort( c.faces, 2 );
            if any(x1(:) ~= x2(:))
                errs = errs+1;
                complainer( 'faceedges->edgeends is not consistent with faces' );
            end
        end
    end
    
% Check consistency of facefes and facefefaces.
%   If facefes(i,:) is [j,k] and facefefaces(i,:) is [p,q], then face i is
%   the p'th face of element j, and either k and q are zero or face i is
%   the q'th face of element k.
    facefeErrs = 0;
    for i=1:numFaces
        f1 = m.FEconnectivity.facefes(i,1);
        ff1 = m.FEconnectivity.facefefaces(i,1);
        f2 = m.FEconnectivity.facefes(i,2);
        ff2 = m.FEconnectivity.facefefaces(i,2);
        ok1 = m.FEconnectivity.fefaces(f1,ff1)==i;
        ok2 = ((f2==0) == (ff2==0)) && ((f2 == 0) || (m.FEconnectivity.fefaces(f2,ff2)==i));
        facefeErrs = facefeErrs + (~ok1) + (~ok2);
    end
    if facefeErrs > 0
        errs = errs+1;
        complainer( 'fefaces is not consistent with facefes and facefefaces, %d errors', facefeErrs );
        ok = false;
    end
    
    
    
% Check consistency of listing edges compared with fe.edges.

    x1 = sort( reshape( c.edgeends( c.feedges', : ), edgesPerFE, numFEs, 2 ), 3 );
    x2 = sort( permute( reshape( m.FEsets.fevxs( :, m.FEsets.fe.edges ), numFEs, 2, edgesPerFE ), [3 1 2] ), 3 );
    if any(x1(:) ~= x2(:))
        errs = errs+1;
        complainer( 'Inconsistent listing of edges in m.FEconnectivity.feedges vs. m.FEsets.fe.edges' );
    end
    
% Check consistency of listing faces compared with fe.faces.

% ERROR for P6 elements.
%     x1 = sort( reshape( c.faces( c.fefaces', : ), facesPerFE, numFEs, vxsPerFace ), 3 );
%     x2 = sort( permute( reshape( m.FEsets.fevxs( :, m.FEsets.fe.faces ), numFEs, vxsPerFace, facesPerFE ), [3 1 2] ), 3 );
%     if any(x1(:) ~= x2(:))
%         errs = errs+1;
%         complainer( 'Inconsistent listing of faces in m.FEconnectivity.fefaces vs. m.FEsets.fe.faces' );
%     end

% Check consistency of classification of faces, edges, and vertexes.
% A surface face must have surface or edge edges, and surface, edge, or corner vertexes.
% A surface edge must have surface or corner vertexes.

% ERROR for P6 elements.
%     surfaceFaceEdgeTypes = unique( c.edgeloctype(c.faceedges( c.faceloctype, : )) );
%     bad = find(any(surfaceFaceEdgeTypes==0,2));
%     if ~isempty(bad)
%         errs = errs+1;
%         complainer( '%d surface faces have interior edges', length(bad) );
%         bad
%     end

% ERROR for P6 elements.
%     surfaceFaceVxTypes = unique( c.vertexloctype(c.faces( c.faceloctype, : )) );
%     bad = find(any(surfaceFaceVxTypes==0,2));
%     if ~isempty(bad)
%         errs = errs+1;
%         complainer( '%d surface faces have interior vertexes', length(bad) );
%         bad
%     end
    surfaceEdgeVxTypes = unique( c.vertexloctype(c.edgeends( c.edgeloctype>0, : )) );
    bad = find(any(surfaceEdgeVxTypes==0,2));
    if ~isempty(bad)
        errs = errs+1;
        complainer( '%d surface edges have interior vertexes', length(bad) );
        bad
    end
    
    % Every surface edge must belong to at least two surface faces.  % Why
    % not exactly two?
    surfaceEdgeFaces = c.edgefaces( c.edgeloctype>0, : );
    surfaceEdgeFaces(surfaceEdgeFaces>0) = c.faceloctype(surfaceEdgeFaces(surfaceEdgeFaces>0));
    surfaceFacesPerSurfaceEdge = sum( surfaceEdgeFaces > 0, 2 );
    bad = find(surfaceFacesPerSurfaceEdge ~= 2);
    if ~isempty(bad)
        errs = errs+1;
        complainer( '%d surface edges belong to other than two surface faces', length(bad) );
        bad
        surfaceEdgeFaces_bad = surfaceEdgeFaces(bad)
        xxxx = 1;
    end
    
    
    
    % Each element must have distinct faces.
    sortedfefaces = sort( m.FEconnectivity.fefaces, 2 );
    repeatedfefaces = sortedfefaces(:,1:(end-1)) == sortedfefaces(:,2:end);
    badfefaces = any(repeatedfefaces,2);
    if any(badfefaces)
        errs = errs+1;
        complainer( '%d elements contain one or more repeated faces', sum(badfefaces) );
        badfefaces'
    end
        
    % Each element must have distinct edges.
    sortedfeedges = sort( m.FEconnectivity.feedges, 2 );
    repeatedfeedges = sortedfeedges(:,1:(end-1)) == sortedfeedges(:,2:end);
    badfeedges = any(repeatedfeedges,2);
    if any(badfeedges)
        errs = errs+1;
        complainer( '%d elements contain one or more repeated faces', sum(badfeedges) );
        badfeedges'
    end
        
    % Each edge must have distinct ends.
    badedges = m.FEconnectivity.edgeends(:,1) == m.FEconnectivity.edgeends(:,2);
    if any(badedges)
        errs = errs+1;
        complainer( '%d edges have identical ends', sum(badedges) );
        badedges'
    end
    
    % Each face must have distinct edges.
    
    
    
    % Each face must have distinct vertexes.
    sortedfacevxs = sort( m.FEconnectivity.faces, 2 );
    repeatedfacevxs = sortedfacevxs(:,1:(end-1)) == sortedfacevxs(:,2:end);
    badfacevxs = any(repeatedfacevxs,2);
    if any(badfacevxs)
        errs = errs+1;
        complainer( '%d faces contain one or more repeated vertexes', sum(badfacevxs) );
        badfacevxs'
    end
    
    
    
    % Each face belongs to at most two tetrahedra.
    
    sortfefaces = sort( m.FEconnectivity.fefaces(:) );
    [starts, ends] = runends( sortfefaces );
    runlengths = ends-starts;
    if any(runlengths >= 2)
        errs = errs+1;
        complainer( '%d faces belong to more than two elements', sum(runlengths >= 2) );
    end
    
    % Two tetrahedra cannot share more than one face.
    facefes = invertIndexArray( m.FEconnectivity.fefaces, size(m.FEconnectivity.faceedges,1), 'array' );
    
    
    
    ok = ok && (errs==0);
    
    function checkvalues( field, data, maxval, allowzero )
        if isempty(data)
            if isfield( c, field )
                data = c.(field);
            end
        end
        if isempty(data)
            return;
        end
        mx = max( reshape( data(:), [], 1 ) );
        mn = max( reshape( data(:), [], 1 ) );
        if mx > maxval
            errs = errs+1;
            % Error
            complainer( '%s maximum is %d, exceeds allowed %d', field, mx, maxval );
        end
        if (mn < 0) || (~allowzero && (mn < 1))
            errs = errs+1;
            % Error
            complainer( '%s minimum is %d, below allowed %d', field, mn, ~allowzero );
        end
    end

    function checksize( field, data, sz1, sz2 )
        if isempty(data)
            if isfield( c, field )
                data = c.(field);
            else
                errs = errs+1;
                % Error.
                return;
            end
        end
        sz = size( data );
        if length(sz) > 2
            errs = errs+1;
            complainer( '%s has %d dimensions, expect 2', field, length(sz) );
        end
        if sz1 ~= sz(1)
            % error
            errs = errs+1;
            complainer( '%s has %d rows, expect %d', field, sz1, sz(1) );
        end
        if (sz2 ~= 0) && (sz2 ~= sz(2))
            % error
            errs = errs+1;
            complainer( '%s has %d columns, expect %d', field, sz2, sz(2) );
        end
    end
end