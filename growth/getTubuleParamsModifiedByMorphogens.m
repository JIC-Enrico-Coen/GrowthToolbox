function params = getTubuleParamsModifiedByMorphogens( m, a, b )
%params = getTubuleParamsModifiedByMorphogens( m, s )
%   Obtain the effective microtubule parameters at the head or the tail of
%   the tubule s: the tail for parameters whose names contain 'minus', and
%   the head for all others.
%
%params = getTubuleParamsModifiedByMorphogens( m, elements, bcs )
%   Get the microtubule parameters at the places represented by a set of
%   elements and bary coords within each element.
%
%params = getTubuleParamsModifiedByMorphogens( m )
%   Get per-vertex values of all microtubule parameters.

    getAllVxs = nargin==1;
    getForTubule = nargin==2;
    getPoints = nargin > 2;
    
    if getForTubule
        if isemptystreamline( a )
            params = [];
            return;
        end
        s = a;
    end
    
    if getPoints
        if isempty(a) || isempty(b)
            params = [];
            return;
        end
        cis = a;
        bcs = b;
    end
    
    params = m.tubules.tubuleparams;
    
    fns = fieldnames( params );
    for i=1:length(fns)
        fn = fns{i};
        if isnumeric(params.(fn)) && (numel(params.(fn))==1)
            continue;
        end
        if ischar( params.(fn) )
            mi = FindMorphogenIndex( m, m.tubules.tubuleparams.(fn) );
            if isempty(mi)
                params.(fn) = 0;
                continue;
            end
            pervertex = m.morphogens(:,mi);
        elseif isempty(params.(fn))
            pervertex = zeros( getNumberOfVertexes(m), 1 );
        elseif length( params.(fn) )==getNumberOfVertexes(m)
            pervertex = params.(fn);
        else
            params.(fn) = 0;
            continue;
        end
        
        if getAllVxs
            params.(fn) = pervertex;
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
            params.(fn) = bc * pervertex( m.tricellvxs( ci, : ) );
        else
            params.(fn) = sum( reshape( pervertex( m.tricellvxs( cis, : ) ), [], 3 ) .* bcs, 2 );
        end
    end
end
