function paramValues = getTubuleParamsModifiedByMorphogens( m, varargin )
%params = getTubuleParamsModifiedByMorphogens( m, s, selectedparams )
%   Obtain the effective microtubule parameters at the head or the tail of
%   the tubule s: the tail for parameters whose names contain 'minus', and
%   the head for all others.
%
%params = getTubuleParamsModifiedByMorphogens( m, elements, bcs, selectedparams )
%   Get the microtubule parameters at the places represented by a set of
%   elements and bary coords within each element.
%
%params = getTubuleParamsModifiedByMorphogens( m, selectedparams )
%   Get per-vertex values of all microtubule parameters.
%
%   SELECTEDPARAMS defaults to all parameters.
%
%   When a parameter is found to take the same value at all the places it
%   is requested, the result will contain just that single value, not an
%   array of values per vertex, or per tubule vertex, or per tubule.

    args = varargin;
    haveParams = iscell( args{end} ) || ischar( args{end} );
    if haveParams
        selectedparams = args{end};
        args(end) = [];
    else
        selectedparams = fieldnames( m.tubules.tubuleparams );
    end
    if ischar( selectedparams )
        selectedparams = { selectedparams };
    end
    
    getAllVxs = isempty(args);
    getForTubule = length(args)==1;
    getPoints = length(args) > 1;
    
    if getForTubule
        a = varargin{1};
        if isemptystreamline( a )
            paramValues = [];
            return;
        end
        s = a;
        numvertexes = 1;
    elseif getPoints
        a = varargin{1};
        b = varargin{2};
        if isempty(a) || isempty(b)
            paramValues = [];
            return;
        end
        cis = a;
        bcs = b;
        numvertexes = length(cis);
    else
        numvertexes = getNumberOfVertexes( m );
    end
    
    paramValues = struct();
    allParams = m.tubules.tubuleparams;
    
    fns = selectedparams;
    for i=1:length(fns)
        fn = fns{i};
        
        if getForTubule && isfield( s, 'overrideparams' ) && isfield( s.overrideparams, fn )
            overridevalue = s.overrideparams.(fn);
            allParams.(fn) = overridevalue;
            xxxx = 1;
        end
        
%         if isnumeric(allParams.(fn)) && (size(allParams.(fn),1)==1)
%             paramValues.(fn) = repmat( allParams.(fn), numvertexes, 1 );
%             continue;
%         end
        if ischar( allParams.(fn) )
            mi = FindMorphogenIndex( m, m.tubules.tubuleparams.(fn) );
            if isempty(mi)
                paramValues.(fn) = 0;
                continue;
            end
            pervertex = m.morphogens(:,mi);
        elseif isempty(allParams.(fn))
            pervertex = 0; % zeros( numvertexes, 1 );
        elseif size( allParams.(fn), 1 )==numvertexes
            pervertex = allParams.(fn);
        elseif size( allParams.(fn), 1 ) ~= 1
            pervertex = zeros( 1, size( allParams.(fn), 2 ) );
%             paramValues.(fn) = 0;
%             continue;
        else
            pervertex = allParams.(fn);
        end
        
        if all( all( pervertex==pervertex(1,:) ) )
            paramValues.(fn) = pervertex(1,:);
        elseif getAllVxs
            paramValues.(fn) = pervertex;
        elseif getForTubule
            atstart = contains( fn, 'minus' );
            if atstart
                bc = s.barycoords(1,:);
                ci = s.vxcellindex(1);
            else
                bc = s.barycoords(end,:);
                ci = s.vxcellindex(end);
            end
            if size(pervertex,1)==1
                paramValues.(fn) = pervertex;
            else
                paramValues.(fn) = bc * pervertex( m.tricellvxs( ci, : ) );
            end
        else
            if size(pervertex,1)==1
                paramValues.(fn) = repmat( pervertex, length(cis), 1 );
            else
                paramValues.(fn) = sum( reshape( pervertex( m.tricellvxs( cis, : ) ), [], 3 ) .* bcs, 2 );
            end
        end
        
%         if ~isempty( paramValues.(fn) ) && all( paramValues.(fn)==paramValues.(fn)(1) )
%             paramValues.(fn) = paramValues.(fn)(1);
%         end
    end
end
