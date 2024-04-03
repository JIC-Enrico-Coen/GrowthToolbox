function param = getTubuleParamModifiedByMorphogens( m, fn, a, b )
%param = getTubuleParamModifiedByMorphogens( m, fn, s )
%   Obtain the effective microtubule parameters at the head or the tail of
%   the tubule s: the tail for parameters whose names contain 'minus', and
%   the head for all others.
%
%param = getTubuleParamModifiedByMorphogens( m, fn, elements, bcs )
%   Get the microtubule parameters at the places represented by a set of
%   elements and bary coords within each element.
%
%param = getTubuleParamModifiedByMorphogens( m, fn )
%   Get per-vertex values of all microtubule parameters.
%
%   This is for foliate meshes only, because tubules are not implemented
%   for volumetric meshes.

    param = [];
    
    if ~isfield( m.tubules.tubuleparams, fn )
        return;
    end
    
    getAllVxs = nargin==2;
    getForTubule = nargin==3;
    getPoints = nargin > 3;
    
    if getAllVxs
        numPoints = getNumberOfVertexes( m );
    elseif getForTubule
        if isemptystreamline( a )
            return;
        end
        s = a;
        numPoints = 1;
    elseif getPoints
        if isempty(a) || isempty(b)
            return;
        end
        cis = a;
        bcs = b;
        numPoints = length(cis);
    end
    
    param = m.tubules.tubuleparams.(fn);
    
    if isnumeric(param) && (size(param,1)==1)
        % The parameter is not position-dependent. Replicate its fixed
        % value according to the number of values demanded.
        param = repmat( param, numPoints, 1 );
        return;
    end
    
    if ischar( param )
        % The parameter specifies a morphogen by name.
        mi = FindMorphogenIndex( m, param );
        if isempty(mi)
            % No value: return zeros.
            param = zeros( numPoints, 1 );
            return;
        end
        pervertex = m.morphogens(:,mi);
    elseif isempty(param)
        % No value: return zeros.
        pervertex = zeros( numPoints, 1 );
    else
        % param is assumed to specify one value per vertex.
        pervertex = param;
    end
    numParams = size(param,2);
    
    % At this point, pervertex is the value of the params at every
    % vertex of the mesh.

    if getAllVxs
        % Done.
        param = pervertex;
    elseif getForTubule
        % We need the params at either the head of the tail of the tubule.
        % (Do we ever use this?)
        atstart = contains( fn, 'minus' );
        if atstart
            bc = s.barycoords(1,:);
            ci = s.vxcellindex(1);
        else
            bc = s.barycoords(end,:);
            ci = s.vxcellindex(end);
        end
        if any(isinf(pervertex( m.tricellvxs( ci, : ) )))
            xxxx = 1;
        end
        param = zeros( 1, numParams );
        for pi = 1:numParams
            param(1,pi) = bc * pervertex( m.tricellvxs( ci, : ), pi );
        end
        paramx = bc * pervertex( m.tricellvxs( ci, : ) );
        xxxx = 1;
    else
        % We want the params for a set of points specified by elements and
        % barycentric coordinates.
        numElements = length(cis);
        vxsPerElement = size( m.tricellvxs, 2 );
        paramx = zeros( numElements, numParams );
        for pi = 1:numParams
            pervertex1 = pervertex( :, pi );
            paramx(:,pi) = sum( reshape( pervertex1( m.tricellvxs( cis, : ) ), [], vxsPerElement ) .* bcs, 2 );
        end
        if numElements==1
            % The calculation is much simpler for this case.
            foo1 = pervertex( m.tricellvxs( cis, : ), : ); % vxsPerElement x numParams
            param = sum( foo1 .* bcs', 1 ); % 1 x numParams
        else
            foo1 = pervertex( m.tricellvxs( cis, : )', : ); % (vxsPerElement * numElements) x numParams
            foo2 = reshape( foo1, vxsPerElement, numElements, numParams ); % vxsPerElement x numElements x numParams
            foo3 = permute( foo2, [2 1 3] ); % numElements x vxsPerElement x numParams
            foo4 = sum( foo3 .* bcs, 2 ); % numElements x 1 x numParams
            param = reshape( foo4, numElements, numParams ); % numElements x numParams
        end
        
        if numParams==1
            if (length(size(paramx)) ~= length(size(param))) || any( size(paramx) ~= size(param) ) || any( paramx(:) ~= param(:) )
                xxxx = 1;
                error( 'getTPMBM old version inconsistent with new (1)' );
            end
        end
        if size( unique( pervertex, 'rows' ), 1 ) == 1
            if (size( unique( paramx, 'rows' ), 1 ) ~= 1) || (size( unique( param, 'rows' ), 1 ) ~= 1)
                xxxx = 1;
                error( 'getTPMBM old version inconsistent with new (2)' );
            end
        end
        xxxx = 1;
    end
end
