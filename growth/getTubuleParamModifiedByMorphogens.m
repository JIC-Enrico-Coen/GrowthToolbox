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
    
    getAllVxs = nargin==2;
    getForTubule = nargin==3;
    getPoints = nargin > 3;
    
    if getForTubule
        if isemptystreamline( a )
            return;
        end
        s = a;
    end
    
    if getPoints
        if isempty(a) || isempty(b)
            return;
        end
        cis = a;
        bcs = b;
    end
    
    if ~isfield( m.tubules.tubuleparams, fn )
        return;
    end
    
    param = m.tubules.tubuleparams.(fn);
    
    if isnumeric(param) && (numel(param)==1)
        return;
    end
    
    if ischar( param )
        mi = FindMorphogenIndex( m, param );
        if isempty(mi)
            param = 0;
            return;
        end
        pervertex = m.morphogens(:,mi);
    elseif isempty(param)
        pervertex = zeros( getNumberOfVertexes(m), 1 );
    else
        pervertex = param;
    end

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
        param = bc * pervertex( m.tricellvxs( ci, : ) );
    else
        param = sum( reshape( pervertex( m.tricellvxs( cis, : ) ), [], 3 ) .* bcs, 2 );
    end
end
