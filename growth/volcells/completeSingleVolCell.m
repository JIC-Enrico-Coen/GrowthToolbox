function volcells = completeSingleVolCell( vxs3d, faceIndexing )
%volcells = completeSingleVolCell( vxs3d, faceIndexing )
%   Make a volcells structure from the given set of vertex positions VXS3D
%   and the list of faces FACEINDEXING. These are assumed to be the faces
%   of a single volumetric cell.

    numvxs = size( vxs3d, 1 );
    numfaces = length( faceIndexing );
    volcells = struct();
    volcells.vxs3d = vxs3d;
    volcells.facevxs = faceIndexing;
    volcells.polyfaces = { uint32(1:numfaces)' };
    volcells.polyfacesigns = { true(numfaces,1) };
    volcells.vxfe = zeros( numvxs, 1, 'uint32' );
    volcells.vxbc = zeros( numvxs, 4 );
    [volcells.edgevxs,volcells.edgefaces,volcells.faceedges] = makeEdges( faceIndexing );
    volcells.atcornervxs = true( numvxs, 1 );
    volcells.onedgevxs = true( numvxs, 1 );
    volcells = setSurfaceElements( volcells );
    
    validVolcells( volcells );
end

