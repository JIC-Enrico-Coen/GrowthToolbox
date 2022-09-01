function volcells = setSurfaceElements( volcells )
%volcells = setSurfaceElements( volcells )
%   Determine which vertexes, edges, faces, and volumes of volcells are on
%   the surface, and set the corresponding members of volcells.

    [volcells.surfacevxs,volcells.surfaceedges,volcells.surfacefaces,volcells.surfacevolumes] = getSurfaceElements( volcells );
end