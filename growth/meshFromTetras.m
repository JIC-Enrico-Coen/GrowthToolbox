function [m,volumes,quality] = meshFromTetras( vxs, tetras )
%m = meshFromTetras( vxs, tetras )
%   Create a GFtbox volumetric mesh made of tetrahedral elements from VXS,
%   an N*3 array of the N vertex positions, and TETRAS, an M*4 array
%   specifying the vertex indexes of each of M tetrahedra.
%
%   To work in GFtbox, all of the tetrahedrons must be specifed with their
%   vertexes listed in right-handed order, i.e. if the tetrahedron were
%   regular, the vertexes in the order listed would form a right-handed
%   spiral. This can be checked with the form:
%
%[m,volumes] = meshFromTetras( vxs, tetras )
%   The VOLUMES result will be an array of the volumes of all the
%   tetrahedra. Right-handed ones have positive volume, left-handed
%   negative. Zero-volume tetrahedra must be avoided, and the ratio of
%   the largest volume to the smallest should be kept moderate. Up to 10 is
%   ok, maybe up to 100.
%
%   This procedure may be useful if you want to import a tetrahedral mesh
%   made outside GFtbox.
%
%[m,volumes,quality] = meshFromTetras( vxs, tetras )
%   NOT YET SUPPORtED.
%   The QUALITY output will return some measure of the quality of each
%   tetrahedron. The regular tetrahedron is the one of highest possible
%   quality. Low quality teteahedra are those which are much narrower in at
%   least one direction than in at least one other direction.

    if nargout > 1
        firstVxs = vxs( tetras(:,1), : );
        v12 = permute( vxs( tetras(:,2), : ) - firstVxs, [2 3 1] );
        v13 = permute( vxs( tetras(:,3), : ) - firstVxs - firstVxs, [2 3 1] );
        v14 = permute( vxs( tetras(:,4), : ) - firstVxs - firstVxs, [2 3 1] );
        tetvecs = [ v12, v13, v14 ];
        numtetras = size(tetras,1);
        dets = zeros( numtetras, 1 );
        for ti=1:numtetras
            dets(ti) = det( tetvecs(:,:,ti) );
        end
        volumes = dets/6;
        lefthanded = volumes < 0;
        tetras(lefthanded,:) = tetras(lefthanded,[1 2 4 3]);
        numlefthanded = sum(lefthanded);
        if numlefthanded > 0
            timedFprintf( '%d of %d tetrahedra were left-handed, converted to right-handed.\n', numlefthanded, numtetras );
        end
        % The following code attempts to compute a measure of "quality" of
        % each tetrahedron, but the current version is not good. Something
        % better may follow.
%         if nargout > 2
%             longestedge = squeeze( max( sqrt( sum( tetvecs.^2, 1 ) ), [], 2 ) );
%             cubevol = squeeze( prod( sqrt( sum( tetvecs.^2, 1 ) ), 2 ) );
%             quality = volumes ./ cubevol;
%         end
    end
    
    m.FEnodes = vxs;
    m.FEsets.fevxs = tetras;
    m.FEsets.fe = FiniteElementType.MakeFEType('T4Q');
    m = completeVolumetricMesh( m );
end
