function [ok,errs] = validVolcells( volcells, m )
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

    numvxs = size( volcells.vxs3d, 1 );
    numedges = size( volcells.edgevxs, 1 );
    numfaces = length( volcells.facevxs );
    numvolumes = length( volcells.polyfaces );
    numdims = 4;
    
    errs = 0;
    
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
    
    % faceedges must be indexed by faces and ends, and reference edges.
    errs = errs + checkSize( 'faceedges', volcells.faceedges, [numfaces 1] );
    errs = errs + checkInRange( 'faceedges', cell2mat( volcells.faceedges ), 1, numedges );
    
    % vxfe must be indexed by vertexes.
    errs = errs + checkSize( 'vxfe', volcells.vxfe, [numvxs 1] );
    
    % vxbc must be indexed by vertexes and dimensions.
    errs = errs + checkSize( 'vxbc', volcells.vxbc, [numvxs numdims] );
    
    % faceedges must list edges in order around the face.
    for fi=1:numfaces
        fv = volcells.facevxs{fi};
        fe = volcells.faceedges{fi};
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
    
    % polyfacesigns must consistently orient the faces of each volume.
    for vi=1:numvolumes
        pf1 = volcells.polyfaces{vi};
        pfs1 = volcells.polyfacesigns{vi};
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
            if numpolyfaceedgesenseerrors > 0
                timedFprintf( 1, 3, 'Volume %d has %d face-edge sense errors for edges', ...
                    vi, numpolyfaceedgesenseerrors );
                fprintf( ' %d', find( polyfaceedgesenseerrors ) );
                fprintf( '\n' );
                errdata = [ foo, double(reshape( repmat(polyfaceedgesenseerrors',2,1), [], 1) ) ]
                errs = errs + numpolyfaceedgesenseerrors;
                xxxx = 1;
            end
            xxxx = 1;
            
            
            
%             % We want an array with three columns: edge index, face index,
%             % and face sign. The first column is voledges defined above,
%             % being the concatenation of faceedges for all of thefaces of
%             % the volcell.
%             % The second and third will now be computed.
%             edgedata = [ voledges, zeros( length(voledges), 2 ) ];
%             ei = 0;
%             for fi=1:length(pf1)
%                 fes = volcells.faceedges{pf1(fi)};
%                 ne = length( fes );
%                 fesenses = volcells.edgevxs( fes, 1 )==volcells.facevxs{pf1(fi)};
%                 edgedata( (ei+1):(ei+ne), 2 ) = pf1(fi);
%                 edgedata( (ei+1):(ei+ne), 3 ) = fesenses==pfs1(fi);
%                 ei = ei + ne;
%             end
%             edgedata1 = sortrows( edgedata );
%             edgesenseerrors = edgedata1(1:2:end,3) == edgedata1(2:2:end,3);
%             numedgesenseerrors = sum( edgesenseerrors );
%             if numedgesenseerrors > 0
%                 timedFprintf( 1, 3, 'Volume %d has %d face-edge sense errors for edges', ...
%                     vi, numedgesenseerrors );
%                 fprintf( ' %d', find( edgesenseerrors ) );
%                 fprintf( '\n' );
%                 errdata = [ edgedata1, double(reshape( repmat(edgesenseerrors',2,1), [], 1) ) ]
%                 errs = errs + numedgesenseerrors;
%             end
        end
    end
    
    if nargin >= 2
        % vxfe must reference elements of m.
        errs = errs + checkInRange( 'vxfe', volcells.vxfe, 1, getNumberOfFEs(m) );
        % Barycentric coords must sum to 1. If m has not been supplied,
        % then vxbc may not have been initialised yet.
        errs = errs + checkBCSum( 'vxbc', volcells.vxbc );
    end
    
    ok = errs == 0;
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
