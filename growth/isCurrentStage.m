function [isstage,stagetime] = isCurrentStage( m, tolerance )
%isCurrentStage( m )
%   Test whether M is currently at a stage time, to within a given
%   fraction (default 0.01) of the time step.

    if nargin < 2
        tolerance = 0.01;
    end
    
    if m.globalProps.recordAllStages
        isstage = true;
        stagetime = m.globalDynamicProps.currenttime;
        timedFprintf( 1, 'recordAllStages, issstage %s, stagetime %g\n', boolchar(isstage), stagetime );
    else
        [dt,mini] = min( abs(m.globalDynamicProps.currenttime - m.stagetimes) );
        isstage = ~isempty(dt) && (dt < m.globalProps.timestep*tolerance);
        if isstage
            stagetime = m.stagetimes(mini);
        else
            stagetime = [];
        end
        timedFprintf( 1, 'tol %g, dt %g, mini %d, issstage %s, stagetime %g\n', tolerance, dt, mini, boolchar(isstage), stagetime );
    end
    
end
