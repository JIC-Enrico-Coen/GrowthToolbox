function edges = shortEdges( m, maxratio, criterion )
%edges = shortEdges( m )
%   Find edges of m that are short enough in their neighbourhood to be
%   considered for eliding.
%
%   For volumetric meshes only.

    if ~isVolumetricMesh(m)
        edges = [];
        return;
    end
    
    numFEs = size( m.FEconnectivity.feedges, 1 );
    edgesPerFE = size( m.FEconnectivity.feedges, 2 );
    
    esqs = edgelengthsqs( m );
    fe_esqs = esqs( m.FEconnectivity.feedges );
    [shortestPerFE,shorteis] = min( fe_esqs, [], 2 );
    shortindexes = sub2ind( size(m.FEconnectivity.feedges), (1:numFEs)', shorteis );
    ratios = fe_esqs ./ repmat( shortestPerFE, 1, edgesPerFE );
    switch criterion
        case 'any'
            tooshort = any( ratios > maxratio.^2, 2 );
        case 'all'
            ratios(shortindexes) = Inf;
            tooshort = all( ratios > maxratio.^2, 2 );
    end
    shortindexes = shortindexes(tooshort);
    edges = m.FEconnectivity.feedges( shortindexes );
end
