function m = leaf_setMTproperty( m, varargin )
%m = leaf_setMTproperty( m, <mtpropertyname>, <per-vertex quantity> )
%   Set microtubule properties from per-vertex quantities.
%
%   Options:
%
%   Each microtubule property name is an option. These are:
%
%   creationrate: the probability per unit area and time of spontaneously
%       creating a microtubule.
%   ...
%
%   The value for each of these options is one of:
%
%       A morphogen name. The value of this morphogen will be used.
%
%       A single number. This value will be applied to every vertex.
%
%       A morphogen value.
%
%       Any other per-vertex quantity that the user constructs.

    global gMTProperties
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    ok = checkcommandargs( mfilename(), s, 'only', gMTProperties );
    if ~ok, return; end
    
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        if isempty(s.(fn))
            continue;
        end
        if ischar( s.(fn) )
            mi = FindMorphogenIndex( m, s.(fn) );
            if isempty(mi) || (mi <= 0)
                continue;
            end
            values = m.morphogens(:,mi);
        elseif numel(s.(fn))==1
            values = ones( getNumberOfVertexes(m), 1 );
        else
            values = s.(fn);
        end
        m.tubules.pervertexprops.(fn) = values;
    end
end
