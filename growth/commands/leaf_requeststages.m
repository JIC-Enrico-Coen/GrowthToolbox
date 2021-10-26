function [m,ok] = leaf_requeststages( m, varargin )
%m = leaf_requeststages( m, ... )
%   Add a set of stage times to the mesh.  None of these will be computed,
%   but a subsequent call to leaf_recomputestages with no explicit stages
%   will compute them.
%
%   Options:
%       'stages'    A list of numerical stage times.  These do not have to
%                   be sorted and may contain duplicates.  The list will be
%                   sorted and have duplicates removed anyway.
%       'mode'      If 'replace', the list will replace any stage times
%                   stored in m.  If 'add' (the default), they will be
%                   combined with those present.
%
%   GUI equivalent: Stages/RequestMore Stages... menu item.  This does not
%   support the 'mode' option and always operates in 'add' mode.
%
%   Topics: Simulation, Project management.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'stages', [], 'mode', 'add' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'stages', 'mode' );
    if ~ok, return; end
    
    if ~strcmp(s.mode,'add')
        m.stagetimes = [];
    end
    m.stagetimes = addStages( m.stagetimes, s.stages );
    saveStaticPart( m );
end
