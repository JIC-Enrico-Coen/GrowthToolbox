function m = leaf_setTubuleParams( m, varargin )
% m = leaf_setTubuleParams( m, varargin )
%
%   Set the parameters that influence the behaviour of microtubules.
%
%   Options:  all names of microtubule parameters. These are listed in the
%   global variable gMTProperties.
%
%   The value of each option can be either a single number, a per-vertex
%   quantity, or the name of a per-vertex morphogen. In the last
%   of these cases, the current value of that morphogen will always be
%   used. If the morphogen name is invalid it will be ignored.
%
%   The options can alternatively be provided as a struct containing all
%   the fields that are to be set.

    global gMTProperties
    
    if isempty(m), return; end
    if length(varargin)==1
        s = varargin{1};
    else
        [s,ok] = safemakestruct( mfilename(), varargin );
        if ~ok, return; end
    end
    ok = checkcommandargs( mfilename(), s, 'only', gMTProperties{:} );
    if ~ok
        return;
    end
    
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        if ischar( s.(fn) )
            mi = FindMorphogenIndex( m, s.(fn) );
%             if ~isempty(mi)
                m.tubules.tubuleparams.(fn) = s.(fn);
%             end
        else
            m.tubules.tubuleparams.(fn) = s.(fn);
        end
    end
end
