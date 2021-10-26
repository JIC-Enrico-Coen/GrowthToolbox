function [edges,faces] = shortFaces( m, maxFEratio )
%[edges,faces] = shortFaces( m )
%   Find faces of m that are short enough in their neighbourhood to be
%   considered for eliding.
%
%   For volumetric meshes only.

    if ~isVolumetricMesh(m)
        edges = [];
        return;
    end
    
    numFEs = size( m.FEconnectivity.feedges, 1 );
    edgesPerFE = size( m.FEconnectivity.feedges, 2 );
    facesPerFE = size( m.FEconnectivity.fefaces, 2 );
    
    esqs = edgelengthsqs( m );
    facemaxedgesqs = max( esqs(m.FEconnectivity.faceedges), [], 2 );
    fefacesizes = facemaxedgesqs( m.FEconnectivity.fefaces );
    [shortestPerFE,shortfis] = min( fefacesizes, [], 2 );
    shortindexes = sub2ind( size(fefacesizes), (1:numFEs)', shortfis );
    ratios = fefacesizes ./ repmat( shortestPerFE, 1, facesPerFE );
    ratios(shortindexes) = Inf;
    tooshort = all( ratios > maxFEratio.^2, 2 );
    shortindexes = shortindexes(tooshort);
    faces = m.FEconnectivity.fefaces( shortindexes );
    edges = m.FEconnectivity.faceedges(faces,:);
    edges = unique(edges);
end
