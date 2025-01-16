function perPoint = interpolateOverSimplexes( perVertex, elementvxs, bcs, interpMode )
%values = interpolateOverSimplexes( perVertex, elementvxs, bcs, interpMode )
%   Interpolate any per-veriex quantity over a mesh, returning its values
%   at the points defined by the list of finite element FES, and for each
%   element, a set of barycentric coordinates BCS. INTERPMODE specifies
%   whether the interpolation is to be done by taking the minimum ('min'),
%   maximum ('max') or mean ('mid' or 'ave').
%
%   If PERVERTEX is a single value, that value is used for all the returned
%   values.
%
%   Wherever a component of BCS is zero, the value at the corresponding
%   vertex is not used in the calculation, regardless of the interpolation
%   mode.
%
%   If a component of BCS is non-zero and the value at the corresponding
%   vertex is NaN, the result will be NaN.
%
%   This function is valid for simplexes of any dimension.

    perPoint = zeros( size(elementvxs,1), 1 );
    
    if (isnumeric(perVertex) || islogical(perVertex)) && (numel( perVertex )==1)
        perPoint(:) = double( perVertex );
        return;
    end
    
    vxsPerElement = size(elementvxs,2);
    perCorner = reshape( perVertex( elementvxs ), [], vxsPerElement );
    
    switch interpMode
        case { 'ave', 'mid' }
            % NaN values that are unreferenced by bcs are ignored.
            perCorner( isnan(perCorner) & (bcs <= 0) ) = 0;
            perPoint = sum( perCorner .* bcs, 2 );
        case 'min'
            % Ignore values unreferenced by bcs.
            perCorner( bcs <= 0 ) = Inf;
            perPoint = min( perCorner, [], 2, 'includenan' );
        case 'max'
            % Ignore values unreferenced by bcs.
            perCorner( bcs <= 0 ) = -Inf;
            perPoint = max( perCorner, [], 2, 'includenan' );
    end
end
