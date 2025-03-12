function perFE = perVertextoperFE( m, perVx, method, fes )
%perFE = perVertextoperFE( m, perVx, method, fes )
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
        fes = method;
        method = 'mid';
        wholemesh = false;
    else
        wholemesh = nargin < 4;
    end
    
    if wholemesh
        perFE = FEvertexToFE( m, perVx, method );
    else
        if isVolumetricMesh(m)
            perFE = perVertextoperPolygon( m.FEsets(1).fevxs, perVx, method, fes );
        else
            perFE = perVertextoperPolygon( m.tricellvxs, perVx, method, fes );
        end
    end
end

