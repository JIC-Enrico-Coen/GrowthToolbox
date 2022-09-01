function [ok,errs,volcells] = validVolcells( volcells, m )
%ok = validVolcells( volcells, m )
%   Check the validity of a volumetric cellular layer.
%   M is optional. If not given, then the values in volcells.vxfe will not
%   be checked for being in range, and vxs3d will not be checked against
%   vxfe and vxbc.

%             vxs3d: [12×3 double]
%           facevxs: {8×1 cell}
%         polyfaces: {[1 2 3 4 5 6 7 8]}
%     polyfacesigns: {[1 1 1 1 1 1 1 1]}
%           edgevxs: [18×2 double]
%         faceedges: {8×1 cell}
%              vxfe: [12×1 double]
%              vxbc: [12×4 double]

    REPORT_polyfaceedgesenseerrors = false;

    numvxs = size( volcells.vxs3d, 1 );
    numedges = size( volcells.edgevxs, 1 );
    numfaces = length( volcells.facevxs );
    numvolumes = length( volcells.polyfaces );
    numdims = 4;
    
    errs = 0;
    
%              vxs3d: [24×3 double]
%            facevxs: {14×1 cell}
%          polyfaces: {[14×1 uint32]}
%      polyfacesigns: {[14×1 logical]}
%               vxfe: [24×1 uint32]
%               vxbc: [24×4 double]
%            edgevxs: [36×2 uint32]
%          edgefaces: {36×1 cell}
%          faceedges: {14×1 cell}
%        atcornervxs: [24×1 logical]
%          onedgevxs: [24×1 logical]
%         surfacevxs: [24×1 logical]
%       surfaceedges: [36×1 logical]
%       surfacefaces: [14×1 logical]
%     surfacevolumes: 1
    errs = errs + checkClass( volcells, 'vxs3d', 'double' );
    errs = errs + checkClass( volcells, 'facevxs', 'uint32' );
    errs = errs + checkClass( volcells, 'polyfaces', 'uint32' );
    errs = errs + checkClass( volcells, 'polyfacesigns', 'logical' );
    errs = errs + checkClass( volcells, 'vxfe', 'uint32' );
    errs = errs + checkClass( volcells, 'vxbc', 'double' );
    errs = errs + checkClass( volcells, 'edgevxs', 'uint32' );
    errs = errs + checkClass( volcells, 'edgefaces', 'uint32' );
    errs = errs + checkClass( volcells, 'faceedges', 'uint32' );
    errs = errs + checkClass( volcells, 'atcornervxs', 'logical' );
    errs = errs + checkClass( volcells, 'onedgevxs', 'logical' );
    errs = errs + checkClass( volcells, 'surfacevxs', 'logical' );
    errs = errs + checkClass( volcells, 'surfaceedges', 'logical' );
    errs = errs + checkClass( volcells, 'surfacefaces', 'logical' );
    errs = errs + checkClass( volcells, 'surfacevolumes', 'logical' );
    
    % facevxs must be indexed by faces, and reference vertexes.
    errs = errs + checkSize( 'facevxs', volcells.facevxs, [numfaces 1] );
    errs = errs + checkInRange( 'facevxs', cell2mat( volcells.facevxs ), 1, numvxs );
    
    % polyfaces must be indexed by volumes, and reference faces.
    errs = errs + checkSize( 'polyfaces', volcells.polyfaces, [numvolumes 1] );
    errs = errs + checkInRange( 'polyfaces', cell2mat( volcells.polyfaces ), 1, numfaces );
    
    % polyfacesigns must be indexed by volumes and assign values per face per
    % poly.
    errs = errs + checkSize( 'polyfacesigns', volcells.polyfacesigns, [numvolumes 1] );
    for vi=1:numvolumes
        errs = errs + checkSize( 'polyfacesigns_i', volcells.polyfacesigns{vi}, [length(volcells.polyfaces{vi}) 1] );
    end
    
    % edgevxs must be indexed by edges and ends, and reference vertexes.
    errs = errs + checkSize( 'edgevxs', volcells.edgevxs, [numedges 2] );
    errs = errs + checkInRange( 'edgevxs', volcells.edgevxs, 1, numvxs );
    
    % edgefaces must be indexed by edges, and reference faces.
    errs = errs + checkSize( 'edgefaces', volcells.edgefaces, [numedges 1] );
    errs = errs + checkInRange( 'edgefaces', cell2mat( volcells.edgefaces ), 1, numfaces );

    % faceedges must be indexed by faces and ends, and reference edges.
    errs = errs + checkSize( 'faceedges', volcells.faceedges, [numfaces 1] );
    errs = errs + checkInRange( 'faceedges', cell2mat( volcells.faceedges ), 1, numedges );
    
    % vxfe must be indexed by vertexes.
    errs = errs + checkSize( 'vxfe', volcells.vxfe, [numvxs 1] );
    
    % vxbc must be indexed by vertexes and dimensions.
    errs = errs + checkSize( 'vxbc', volcells.vxbc, [numvxs numdims] );
    
    % Every vertex must be referenced by some edge.
    alledgevxs = unique( volcells.edgevxs );
    if length(alledgevxs) < numvxs
        timedFprintf( 1, 3, '%d vertexes are not referenced by any edge.\n', ...
            numvxs - length(alledgevxs) );
        errs = errs + 1;
    end
    
    % Every vertex must be referenced by some face.
    allfacevxs = unique( cell2mat( volcells.facevxs ) );
    if length(allfacevxs) < numvxs
        timedFprintf( 1, 3, '%d vertexes are not referenced by any face.\n', ...
            numvxs - length(allfacevxs) );
        errs = errs + 1;
    end
    
    % Every edge must be referenced by some face.
    allfaceedges = unique( cell2mat( volcells.faceedges ) );
    if length(allfaceedges) < numedges
        timedFprintf( 1, 3, '%d edges are not referenced by any face.\n', ...
            numedges - length(allfaceedges) );
        errs = errs + 1;
    end
    
    % Every face must be referenced by some volume.
    allvolfaces = unique( cell2mat( volcells.polyfaces ) );
    if length(allvolfaces) < numfaces
        timedFprintf( 1, 3, '%d faces are not referenced by any volume.\n', ...
            numfaces - length(allvolfaces) );
        errs = errs + 1;
    end
    
    % Every face must have the same number of vertexes as edges, and at
    % least 3. faceedges must list vertexes and edges in the same order
    % around the face.
    for fi=1:numfaces
        fv = volcells.facevxs{fi};
        fe = volcells.faceedges{fi};
        if length(fv) ~= length(fe)
            timedFprintf( 1, 3, 'Face %d has %d vertexes and %d edges.\n', ...
                fi, length(fv), length(fe) );
            errs = errs+1;
            break;
        end
        if length(fv) < 3
            timedFprintf( 1, 3, 'Face %d has only %d vertexes and edges, should have at least 3.\n', ...
                fi, length(fv) );
            errs = errs+1;
            break;
        end
        fee = [ fv, fv([2:end 1]) ];
        edgesense = volcells.edgevxs( fe, 1 )==fv;
        fee( ~edgesense, : ) = fee( ~edgesense, [2 1] );
        agreement = fee==volcells.edgevxs( fe, : );
        cycleerrors = sum(~agreement(:));
        if cycleerrors > 0
            timedFprintf( 1, 3, 'Face %d has %d errors in cyclicity.\n', ...
                fi, cycleerrors );
            errs = errs + cycleerrors;
        end
    end
    
    % Every volume must have at least four faces.
    % polyfaces and polyfacesigns must have the same length.
    % polyfacesigns must consistently orient the faces of each volume.
    for vi=1:numvolumes
        pf1 = volcells.polyfaces{vi};
        pfs1 = volcells.polyfacesigns{vi};
        if length(pf1) ~= length(pfs1)
            timedFprintf( 1, 3, 'Volume %d has %d faces and %d face signs.\n', ...
                vi, length(pf1), length(pfs1) );
            errs = errs+1;
            break;
        end
        if length(pf1) < 4
            timedFprintf( 1, 3, 'Volume %d has only %d faces, should have at least 4.\n', ...
                vi, length(pf1) );
            errs = errs+1;
            break;
        end
        % Every edge of any of these faces should occur exactly twice in
        % this set of faces.
        voledges = cell2mat( volcells.faceedges(pf1) );
        numvoledges = length(unique(voledges));
        discrepancy = length(voledges) - 2*numvoledges;
        [a,b] = sumArray( voledges, ones(size(voledges)), [numedges,1] );
        badedges = find( (a~=0) & (a~=2) )';
        badcounts = a(badedges)';
        if ~isempty(badedges)
            timedFprintf( 1, 3, 'Volume %d fails to connect to every edge twice, %d bad edges.\n', ...
                vi, length(badedges) );
            badedges
            badcounts
            errs = errs+1;
        else
            % Maybe a better way. Make an array containing for every edge
            % of the polyhedron, the indexes of the faces containing that
            % edge.
            % 1: edge index
            % 2: face 1
            % 3, 4: vertexes of the edge in face 1
            foo = [ cell2mat( volcells.faceedges(pf1) ), cell2mat( volcells.facevxs(pf1) ) ];
            foo = [ foo, zeros(size(foo,1),2) ];
            fooi = 0;
            for rfi=1:length(pf1)
                fi = pf1(rfi);
                fivxs = volcells.facevxs{fi};
                foo( (fooi+1):(fooi+length(fivxs)), 3 ) = fivxs([2:end 1],1);
                foo( (fooi+1):(fooi+length(fivxs)), 4 ) = volcells.polyfacesigns{vi}(rfi);
                foo( (fooi+1):(fooi+length(fivxs)), 5 ) = rfi;
                foo( (fooi+1):(fooi+length(fivxs)), 6 ) = fi;
                fooi = fooi+length(fivxs);
            end
            foo = sortrows( foo );
            edges1 = foo(1:2:end,[2 3]);
            edges2 = foo(2:2:end,[3 2]);
            edgesagree = all(edges1 == edges2,2);
            signs1 = foo(1:2:end,4);
            signs2 = foo(2:2:end,4);
            signsagree = signs1==signs2;
            polyfaceedgesenseerrors = edgesagree ~= signsagree;
            numpolyfaceedgesenseerrors = sum( polyfaceedgesenseerrors );
            if (numpolyfaceedgesenseerrors > 0) && REPORT_polyfaceedgesenseerrors
                timedFprintf( 1, 3, 'Volume %d has %d face-edge sense errors among %d edges.\n   ', ...
                    vi, numpolyfaceedgesenseerrors, length( polyfaceedgesenseerrors ) );
                fprintf( ' %d', find( polyfaceedgesenseerrors ) );
                fprintf( '\n' );
%                 errdata = [ foo, double(reshape( repmat(polyfaceedgesenseerrors',2,1), [], 1) ) ]
                errs = errs + numpolyfaceedgesenseerrors;
            end
        end
    end
    
    if nargin >= 2
        % vxfe must reference elements of m.
        errs = errs + checkInRange( 'vxfe', volcells.vxfe, 1, getNumberOfFEs(m) );
        % Barycentric coords must sum to 1. If m has not been supplied,
        % then vxbc may not have been initialised yet.
        errs = errs + checkBCSum( 'vxbc', volcells.vxbc );
    end
    
    if isfield( volcells, 'atcornervxs' )
        errs = errs + checkSize( 'atcornervxs', volcells.atcornervxs, [numvxs 1] );
    end
    if isfield( volcells, 'onedgevxs' )
        errs = errs + checkSize( 'onedgevxs', volcells.onedgevxs, [numvxs 1] );
    end
    
    if ~isfield( volcells, 'surfacevxs' )
        volcells = setSurfaceElements( volcells );
    else
        errs = errs + checkSize( 'surfacevxs', volcells.surfacevxs, [numvxs 1] );
        errs = errs + checkSize( 'surfaceedges', volcells.surfaceedges, [numedges 1] );
        errs = errs + checkSize( 'surfacefaces', volcells.surfacefaces, [numfaces 1] );
        errs = errs + checkSize( 'surfacevolumes', volcells.surfacevolumes, [numvolumes 1] );
        [svx,se,sf,svol] = getSurfaceElements( volcells );
        errs1 = checkSame( svx, volcells.surfacevxs, 0, 'computed surfacevxs', 'actual surfacevxs' );
        errs2 = checkSame( se, volcells.surfaceedges, 0, 'computed surfaceedges', 'actual surfaceedges' );
        errs3 = checkSame( sf, volcells.surfacefaces, 0, 'computed surfacefaces', 'actual surfacefaces' );
        errs4 = checkSame( svol, volcells.surfacevolumes, 0, 'computed surfacevolumes', 'actual surfacevolumes' );
        errs1234 = errs1 + errs2 + errs3 + errs4;
        if errs1234 > 0
            volcells.surfacevxs = svx;
            volcells.surfaceedges = se;
            volcells.surfacefaces = sf;
            volcells.surfacevolumes = svol;
        end
        errs = errs + errs1234;
    end

    ok = errs == 0;
    
    if ~ok
        xxxx = 1;
    end
end

function errs = checkClass( volcells, fn, expectedType )
    errs = 0;
    if ~isfield( volcells, fn )
        timedFprintf( 1, 3, 'Field %s is missing.\n', fn );
        errs = 1;
        return;
    end
    f = volcells.(fn);
    
    if iscell( f )
        for i=1:numel( f )
            actualType = class( f{i} );
            errs = errs + 1 - strcmp( actualType, expectedType );
        end
        if errs > 0
            timedFprintf( 1, 3, 'Cell array %s should have class %s, found %s for %d of %d items.\n', ...
                fn, expectedType, actualType, errs, numel( f ) );
        end
    else
        actualType = class( f );
        errs = 1 - strcmp( actualType, expectedType );
        if errs==1
            timedFprintf( 1, 3, 'Field %s should have class %s, found %s.\n', ...
                fn, expectedType, actualType );
        end
    end
end

function errs = checkSame( a, b, tol, namea, nameb )
    ca = class(a);
    cb = class(b);
    errs = 0;
    if ~isa(a,class(b))
        timedFprintf( 1, 3, '%s and %s should have the same class, found %s and %s.\n', ...
            namea, nameb, class(a), class(b) );
        errs = errs+1;
    end
    na = numel(a);
    nb = numel(b);
    if na ~= nb
        timedFprintf( 1, 3, '%s and %s should have the same number of elements, found %d and %d.\n', ...
            namea, nameb, na, nb );
        errs = errs+1;
    else
        errs1 = sum( abs( a(:)-b(:) ) > tol );
        if errs1 > 0
            timedFprintf( 1, 3, '%s and %s should be identical, are different at %d out of %d places.\n', ...
                namea, nameb, errs1, na );
            errs = errs + errs1;
        end
    end
end

function errs = checkBCSum( field, bcs, tol )
    if nargin < 3
        tol = 1e-6;
    end
    sumbcs = sum( bcs, 2 );
    errs = sum( abs( sumbcs-1 ) > tol );
    if errs > 0
        timedFprintf( 1, 3, 'Bary coords %s have %d entries not summing to 1 within %g.\n', ...
            field, errs, tol );
    end
end

function errs = checkSize( field, data, sz )
    szd = size(data);
    szdl = length(szd);
    szl = length(sz);
    if szl==1
        sz = [sz 1];
    end
    if szdl > szl
        sz = [ sz, ones( 1, szdl - szl ) ];
    end
    if szdl ~= szl
        timedFprintf( 1, 3, 'Field %s has wrong number of dimensions: expected %d, found %d.\n', ...
            field, length(sz), szdl );
        errs = 1;
    elseif any(szd ~= sz)
        timedFprintf( 1, 3, 'Field %s has wrong size: expected%s, found%s.\n', ...
            field, sprintf( ' %d', sz ), sprintf( ' %d', szd ) );
        errs = 1;
    else
        errs = 0;
    end
end

function errs = checkInRange( field, data, lo, hi )
    numlo = sum( data(:) < lo );
    numhi = sum( data(:) > hi );
    errs = numlo + numhi;
    if errs > 0
        timedFprintf( 1, 3, 'Field %s has %d elements below %d and %d above %d.\n', field, numlo, lo, numhi, hi );
    end
end
