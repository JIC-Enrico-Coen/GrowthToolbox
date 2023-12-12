function values = interpolateOverMesh( m, perVertex, fes, bcs, interpMode )
%values = interpolateOverMesh( m, perVertex, fes, bcs, interpMode )
%   Interpolate any per-vertex quantity over the mesh, returning its values
%   at the points defined by the list of finite element FES, and for each
%   element, a set of barycentric coordinates BCS. INTERPMODE specifies
%   whether the interpolation is to be done by taking the minimum ('min'),
%   maximum ('max') or mean ('mid' or 'ave').
%
%   PERVERTEX can be the name of a morphogen, in which case the INTERPMODE
%   defaults to the interpolation mode for that morphogen. INTERPMODE
%   otherwise defaults to 'mid'. If the morphogen is not found, the values
%   returned are zero.
%
%   If PERVERTEX is a single value, that value is used for all the returned
%   values.
%
%   Wherever a component of BCS is zero and the value at the corresponding
%   vertex is NaN, that value is not used in the calculation, regardless of
%   the interpolation mode.
%
%   Wherever a component of BCS is zero and the interpolation mode is 'min'
%   or 'max', the value at the corresponding vertex is not used in the
%   calculation, regardless of the interpolation mode.
%
%   This function is valid for both volumetric and foliate meshes.

    values = zeros( length(fes), 1 );
    
    if nargin < 5
        interpMode = 'mid';
    end
    
    if (isnumeric(perVertex) || islogical(perVertex)) && (numel( perVertex )==1)
        values(:) = double( perVertex );
        return;
    end
    
    if ischar( perVertex )
        mgenName = perVertex;
        [mgenIndex,perVertex] = getMgenLevels( m, mgenName );
        if isempty( mgenIndex )
            return;
        end
        if nargin < 5
            interpMode = m.mgen_interpType{ mgenIndex };
        end
    end
    
    if usesNewFEs( m )
        fevxs = m.FEsets(1).fevxs( fes, : );
    else
        fevxs = m.tricellvxs( fes, : );
    end
    
    vxsPerFE = size(fevxs,2);
    perFEVxValue = reshape( perVertex( fevxs ), [], vxsPerFE );
    
%     spacedims = 3;
%     foo1 = m.nodes( m.tricellvxs(fes,:)', : );  % (FEVX * FE) X
%     foo2 = reshape( foo1, vxsPerFE, [], spacedims );  % FEVX FE X
%     foo3 = permute( foo2, [2 1 3] );  % FE FEVX X
%     foo4 = sum( foo3 .* bcs, 2 );  % FE 1 X
%     foo5 = permute( foo4, [1 3 2] );  % FE X
%     foo6 = m.auxdata.planes( m.tricellvxs(fes,:), : );

    switch interpMode
        case { 'ave', 'mid' }
            % NaN values that are unreferenced by bcs are ignored.
            perFEVxValue( isnan(perFEVxValue) & (bcs <= 0) ) = 0;
            values = sum( perFEVxValue .* bcs, 2 );
        case 'min'
            % Ignore values unreferenced by bcs.
            perFEVxValue( bcs <= 0 ) = Inf;
            values = min( perFEVxValue, [], 2, 'includenan' );
        case 'max'
            % Ignore values unreferenced by bcs.
            perFEVxValue( bcs <= 0 ) = -Inf;
            values = max( perFEVxValue, [], 2, 'includenan' );
    end
end
