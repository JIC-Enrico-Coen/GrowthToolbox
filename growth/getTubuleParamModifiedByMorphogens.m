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
    
    % At this point, pervertex is the value of the param at every
    % vertex.

    if getAllVxs
        param = pervertex;
    elseif getForTubule
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
        paramlength = size(param,2);
        param = zeros( 1, paramlength );
        for pi = 1:paramlength
            param(1,pi) = bc * pervertex( m.tricellvxs( ci, : ), pi );
        end
        paramx = bc * pervertex( m.tricellvxs( ci, : ) );
        xxxx = 1;
    else
        paramlength = size(param,2);
        param = zeros( length(cis), paramlength );
        for pi = 1:paramlength
            pervertex1 = pervertex( pi );
            param(:,pi) = sum( reshape( pervertex1( m.tricellvxs( cis, : ) ), [], 3 ) .* bcs, 2 );
        end
        paramx = sum( reshape( pervertex( m.tricellvxs( cis, : ) ), [], 3 ) .* bcs, 2 );
        xxxx = 1;
    end
end
