function perEdge = perVertextoperEdge( m, perVx, method, edges )
%perVx = perVertextoperFE( m, perVx, method, fes )
%   Given a quantity that is defined for each vertex, calculate an
%   equivalent quantity per finite element.
%
%   The per-vertex quantity can be a vector.  If m has numVx vertexes and
%   numFEs finite elements, then perVx has size  [numVxs,K] for some K, and
%   perFE has size [numFEs,K]. 
%
%   Note that this is an approximation: some smoothing is unavoidable in
%   the calculation.  The function perFEtoperVertex translates the other
%   way, but these two functions are not inverses.  Converting back and
%   forth will have the side-effect of spreading out the distribution of
%   the quantity.

    if nargin < 3
        method = 'mid';
        wholemesh = true;
    elseif ~ischar(method)
        edges = method;
        method = 'mid';
        wholemesh = false;
    else
        wholemesh = true;
    end
    
    if isVolumetricMesh( m )
        edgeends = m.FEconnectivity.edgeends;
    else
        edgeends = m.edgeends;
    end
    perVxPair = perVx( edgeends );
    switch method
        case 'max'
            perEdge = max( perVxPair, [], 2 );
        case 'min'
            perEdge = min( perVxPair, [], 2 );
        otherwise
            perEdge = mean( perVxPair, 2 );
    end
    if ~wholemesh
        perEdge = perEdge( edges );
    end
end

