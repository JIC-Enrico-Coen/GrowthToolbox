function [is,stagetime] = isCurrentStage( m, tolerance )
%isCurrentStage( m )
%   Test whether M is currently at a stage time, to within a given
%   fraction (default 0.01) of the time step.

    if nargin < 2
        tolerance = 0.01;
    end
    [dt,mini] = min( abs(m.globalDynamicProps.currenttime - m.stagetimes) );
    is = ~isempty(dt) && (dt < m.globalProps.timestep*tolerance);
    if is
        stagetime = m.stagetimes(mini);
    else
        stagetime = [];
    end
    
%     timedFprintf( 1, '%s: dt %g, mini %d, is %d, stagetime %g\n', dt, mini, is, stagetime );
end
