function perFECorner = perVertextoperFECorner( m, perVx, method, fes )
%perVx = perVertextoperFECorner( m, perVx, method, fes )
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
    elseif ~ischar(method)
        fes = method;
        method = 'mid';
    end
    if ~exist( 'fes', 'var' )
        fes = true( getNumberOfFEs( m ), 1 );
    end
    
    if isVolumetricMesh(m)
        perFECorner = perVx( m.FEsets(1).fevxs( fes, : ) );
    else
        % We should deal with the case where what is wanted is the value
        % per prism node, but we won't.
        perFECorner = perVx( m.tricellvxs( fes, : ) );
    end
    
    switch method
        case { 'mid', 'ave' }
            % Nothing.
        case 'min'
            perFECorner = repmat( min( perFECorner, [], 2 ), 1, size( perFECorner, 2 ) );
        case 'max'
            perFECorner = repmat( max( perFECorner, [], 2 ), 1, size( perFECorner, 2 ) );
        case 'sum'
            perFECorner = repmat( sum( perFECorner, [], 2 ), 1, size( perFECorner, 2 ) );
        otherwise
            % Treat as mid, do nothing.
    end
end

