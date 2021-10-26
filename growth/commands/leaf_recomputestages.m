function [m,ok] = leaf_recomputestages( m, varargin )
%m = leaf_recomputestages( m, ... )
%   Recompute a set of stages of the project, starting from the current
%   state of m.  If this is after any of the stages specified, those stages
%   will not be recomputed.
%
%   Options:
%       'stages'    A list of the stages to be recomputed as an array of
%                   numerical times.  The actual times of the saved stages
%                   will be the closest possible to those specified, given
%                   the starting time and the time step.  If this option is
%                   omitted, it will default to the set of stage times
%                   currently stored in m, which can be set by
%                   leaf_requeststages.
%
%   See also: leaf_requeststages
%
%   Topics: Simulation.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'stages', m.stagetimes, 'plot', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'stages', 'plot' );
    if ~ok, return; end
    if isempty( s.stages ), return; end
    
    stages = s.stages;
    s = rmfield( s, 'stages' );
    m.stagetimes = addStages( m.stagetimes, stages );
    saveStaticPart( m );
    
    endTime = stages(end);
    args = cellFromStruct( s );
    while m.globalDynamicProps.currenttime < endTime - m.globalProps.timestep*0.1
        [m,ok] = leaf_iterate( m, 1, args{:} );
        if ~ok
            fprintf( 1, 'Recompute stages stopped prematurely at time %f.\n', ...
                m.globalDynamicProps.currenttime );
            break;
        else
            fprintf( 1, 'leaf_iterate returned ok=true\n' );
        end
    end
    clearstopbutton( m )
end
