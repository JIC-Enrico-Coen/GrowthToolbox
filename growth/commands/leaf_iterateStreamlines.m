function [m,ok] = leaf_iterateStreamlines( m )
%m = leaf_iterateStreamlines( m )
%   Create new streamlines and develop all of the streamlines for one time step.

    ok = true;
    VERBOSE = false;
    if ~m.globalProps.enabletubules
        return;
    end
    
    m = recalcStreamlineGlobalData( m );

    dt = m.globalProps.timestep;
    m = doTubuleBranching( m, dt );
    m = doTubuleCreation( m, dt );
    
    if isempty( m.tubules.tracks )
        return;
    end
    
    numrescued = 0;
    rescueinfo = zeros(0,5);
    numsevered = 0;
    severinginfo = zeros(0,5);
    ease_of_creation = limitMTcreation( m );
    
    % Perform all pending events that have fallen due.
    si = 0;
    interrupted = false;
    MAXITERS = length( m.tubules.tracks ) * 5;
    TUBULES_PER_DOT = 100;
    numsteps = 0;
    numdots = 0;
    DOTS_PER_LINE = 80;
    oldnumsevs = getNumberOfSeverances( m );
    fprintf( 1, '%s: processing %d severances for %d streamlines.\n', mfilename(), oldnumsevs, length( m.tubules.tracks ) );
    while (si < length( m.tubules.tracks )) && ~interrupted
        if teststopbutton(m)
            interrupted = true;
            break;
        end
        if si > MAXITERS
            xxxx = 1;
        end
        numsteps = numsteps+1;
        if mod(numsteps,TUBULES_PER_DOT)==0
            fwrite( 1, '.' );
            numdots = numdots+1;
            if mod(numdots, DOTS_PER_LINE)==0
                fwrite( 1, newline );
            end
        end
    	si = si+1;
        mt = m.tubules.tracks(si);
        sevs = mt.status.severance;
        if isempty(sevs)
            continue;
        end
        [~,perm] = sort( [sevs.vertex], 'descend' );
        for sevi=1:length( sevs )
            sevpi = perm( sevi );
            if sevpi > length( mt.status.severance )
                continue;
            end
            if sevs(sevpi).time > m.globalDynamicProps.currenttime
                % Not yet due.
                continue;
            end
            switch sevs(sevpi).eventtype
                case 'b'
                    % Branching.
                    grantednum = requestMTcreation( m, 1 );
                    if grantednum > 0
%                         timedFprintf( 'Creating pending branch.\n' );
                        UNIFORM_CROSSOVER_BRANCHING = true;
                        if UNIFORM_CROSSOVER_BRANCHING
                            branchSides = randSign(1,1);
                            branchAngles = rand(1) * pi;
                            [m,newbranchinfo,newmtindexes] = spawnBranches( m, si, sevs(sevpi).vertex, [1 0], ...
                                    sevs(sevpi).time - m.globalDynamicProps.currenttime, ...
                                    branchSides, branchAngles );
                        else
                            [m,newbranchinfo,newmtindexes] = spawnBranches( m, si, sevs(sevpi).vertex, [1 0], ...
                                    sevs(sevpi).time - m.globalDynamicProps.currenttime );
                        end
                        sevs(sevpi).eventtype = 'x';
                        for ti=1:newmtindexes
                            m.tubules.tracks(ti).status.interactiontime = m.tubules.tubuleparams.branch_interaction_delay;
                        end
    
                        % Update stats.
%                         if ~isfield( m.tubules.statistics, 'xoverbranchings' )
%                             m.tubules.statistics.xoverbranchings = 0;
%                         end
%                         m.tubules.statistics.xoverbranchings = m.tubules.statistics.xoverbranchings + grantednum;
                        m.tubules.statistics.xoverbranchinfo = [ m.tubules.statistics.xoverbranchinfo; newbranchinfo ];
                    end
                    
                case 's'
                    % Severance.
                    headcat = rand(1) < m.tubules.tubuleparams.prob_collide_cut_headcat;
                    if ~headcat
                        % The head of the tail section is supposed to grow, but
                        % if we cannot get a new growing head, we catastrophe
                        % instead.
                        grantednum = requestMTcreation( m, 1 );
                        headcat = grantednum==0;
                    end
                    tailcat = rand(1) > (1-m.tubules.tubuleparams.prob_collide_cut_tailcat) * ease_of_creation;
                    [mttail,mthead] = splitMT( m, mt, sevs(sevpi).vertex, tailcat, headcat );
                    if isempty( mthead )
                        mttail.status.severance(sevpi) = [];
                        deltasev = length(mttail.status.severance) - length(mt.status.severance);
                    else
                        m.tubules.maxid = m.tubules.maxid+1;
                        mthead.id = m.tubules.maxid;
                        deltasev = length(mttail.status.severance) + length(mthead.status.severance) - length(mt.status.severance);
                        m.tubules.tracks(end+1) = mthead;
                        m.tubules.tracks(si) = mttail;
%                         m.tubules.statistics.severings = m.tubules.statistics.severings+1;
                        % severinginfo
                        numsevered = numsevered+1;
                        severinginfo( numsevered, : ) = [ sevs(sevpi).FE, sevs(sevpi).bc, Steps(m)+1 ];
%     pendingEvent = struct( ...
%             'time', m.globalDynamicProps.currenttime + delay, ...
%             'vertex', vx, ...
%             'FE', splitmt.vxcellindex(vx), ...
%             'bc', splitmt.barycoords(vx,:), ...
%             ... % 'globalpos', splitmt.globalcoords(vx,:), ...
%             'eventtype', eventType ...
%         );

                    end
                    mt = mttail;
                    if deltasev >= 0
                        xxxx = 1;
                    end
                    newnumsevs = getNumberOfSeverances( m );
                    if newnumsevs > oldnumsevs
                        timedFprintf( 1, 'Error: after processing severances, there are %d new severances.\n', newnumsevs - oldnumsevs );
                        xxxx = 1;
                    end
                    
                case 'x'
                    % Ignore.
                
                otherwise
                    timedFprintf( 1, 'Unknown pending event type ''%s''.\n', sevs(sevpi).type );
                    xxxx = 1;
            end
        end
    end
    
    % Remove all resolved events.
    for i=1:length( m.tubules.tracks )
        sevs = [m.tubules.tracks(i).status.severance];
        if ~isempty( sevs )
            expired = [sevs.eventtype] == 'x';
            if any( expired )
                xxxx = 1;
            end
            m.tubules.tracks(i).status.severance( expired ) = [];
        end
    end
    
    newnumsevs = getNumberOfSeverances( m );
    if newnumsevs > oldnumsevs
        fprintf( 1, '%s: Error: after processing severances, there are %d new severances.\n', mfilename(), newnumsevs - oldnumsevs );
        xxxx = 1;
    end
    if mod(numdots, DOTS_PER_LINE) ~= 0
        fwrite( 1, newline );
    end
    if oldnumsevs > 0
        fprintf( 1, '%s: After processing severances, there are %d streamlines. %d steps, %d dots.\n', ...
            mfilename(), length( m.tubules.tracks ), numsteps, numdots );
    end
    numsteps = 0;
    numdots = 0;
    
    npsafter = numPendingSeverances( m );
    % May want to report oldnumsevs and npsafter.
    xxxx = 1;
    if interrupted
        ok = false;
        return;
    end
    
    % Grow the steamlines.
    if ~isempty( m.tubules.tracks )
        fprintf( 1, '%s: growing %d streamlines.\n', mfilename(), length( m.tubules.tracks ) );
    end
    for si=1:length( m.tubules.tracks )
        s = m.tubules.tracks(si);
        if isemptystreamline(s)
            continue;
        end
        old_s = s;
        if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
            xxxx = 1;
        end
        
        if teststopbutton(m)
            interrupted = true;
            break;
        end
        
        if all(s.directionglobal==0)
            xxxx = 1;
        end
        
        if ~validStreamline( m, s, VERBOSE )
            if VERBOSE
                fprintf( 'Invalid streamline %d.\n', si );
                BREAKPOINT( 'Invalid streamline %d.\n', si );
            end
        end
        
        simstarttime = max( m.globalDynamicProps.currenttime, s.starttime );  
        
        % Start the tail shrinking if it was delayed and the delay has
        % expired.
        if (m.tubules.tubuleparams.branch_shrinktail_delay > 0) ...
                && ~s.status.shrinktail ...
                && (s.status.shrinktime ~= 0) ...
                && (s.status.shrinktime <= m.globalDynamicProps.currenttime)
            s.status.shrinktail = true;
        end
    
        MAXITERS = 50;
        numiters = 0;
        remainingtime = dt - (simstarttime - m.globalDynamicProps.currenttime);
        ok1 = true;
        while ok1 && (remainingtime > dt * 1e-5) && ~isemptystreamline( s )
            numsteps = numsteps+1;
            if mod(numsteps,1)==0
                fwrite( 1, '.' );
                numdots = numdots+1;
                if mod(numdots, DOTS_PER_LINE)==0
                    fwrite( 1, newline );
                end
            end
        
            numiters = numiters+1;
            if numiters >= MAXITERS
                BREAKPOINT( '%s: mt %d requires too many iterations %d.\n', mfilename(), si, numiters );
                ok1 = false;
                break;
            end
            params = getTubuleParamsModifiedByMorphogens( m, s );
            oldheadstatus = s.status.head;
            switch oldheadstatus
                case 1
                    % Is growing. Might continue, stop or start shrinking,
                    % but that will be handled by extendStreamline().
                    timeused = remainingtime;
                case 0
                    % Is stopped. Never changes from this state.
                    timeused = remainingtime;
                case -1
                    % Is shrinking. Might continue or be rescued.
                    nextrescue = sampleexp( params.prob_plus_rescue * ease_of_creation );
                    if nextrescue < remainingtime
                        % A rescued tubule may change its direction,
                        % according to the parameters rescue_angle_mean and
                        % rescue_angle_spread, if present; otherwise the
                        % original direction is maintained.
                        s.status.head = 1;
                        numrescued = numrescued+1;
                        rescueinfo( numrescued, : ) = [ s.vxcellindex(end), s.barycoords(end,:), Steps(m)+1 ];
                        timeused = nextrescue;
                        
                        if isfield( params, 'rescue_angle_mean' ) && ~isempty(params.rescue_angle_mean)
                            deviation = (params.rescue_angle_mean + params.rescue_angle_spread * randn( 1 )) * randSign( 1 );
                            currentDirection = s.directionglobal;
                            currentElement = s.vxcellindex(end);
                            elementNormal = m.cellFrames(:,3,currentElement)';
                            elementVxs = m.nodes( m.tricellvxs( currentElement, : ), : );
                            newDirection = rotateVecAboutVec( currentDirection, elementNormal, deviation );
                            [theDirBcs,dbc_err] = baryDirCoords( elementVxs, elementNormal, newDirection );
                            xxxx = 1;
                            s.directionglobal = newDirection;
                            s.directionbc = theDirBcs;
                            if ~isfield( m.tubules.statistics, 'rescueangles' )
                                m.tubules.statistics.rescueangles = [];
                            end
                            m.tubules.statistics.rescueangles(end+1) = deviation;
                        end
                    else
                        s.status.head = -1;
                        timeused = remainingtime;
                    end
            end

            switch s.status.head
                case 1
                    headgrowth = params.plus_growthrate * timeused;
                case 0
                    headgrowth = 0;
                case -1
                    headgrowth = -params.plus_shrinkrate * timeused;
            end


            if isemptystreamline( s )
                fprintf( '%s 2: empty tubule found.\n', mfilename() );
                s;
                xxxx = 1;
            end
    
            if headgrowth > 0
                s1 = s;
                [m,s,lengthgrown] = extendStreamline( m, s, headgrowth, si );
                if sum( s.segmentlengths ) < 0.001
                    xxxx = 1;
                end
                if length(s.vxcellindex)==1
                    xxxx = 1;
                end
                timeused = lengthgrown/params.plus_growthrate;
            elseif headgrowth < 0
                slen = sum( s.segmentlengths );
                s = shrinkStreamline( m, s, -headgrowth, true );
                slen2 = sum( s.segmentlengths );
                timeused = (slen - slen2)/params.plus_shrinkrate;
            end
            
            slen = sum( s.segmentlengths );
            if slen > 0
                if s.status.catshrinktail
                    tailshrinkrate = params.minus_catshrinkrate;
                else
                    tailshrinkrate = params.minus_shrinkrate;
                end
                tailshrink = tailshrinkrate * timeused;
                if tailshrink > 0
                    s = shrinkStreamline( m, s, tailshrink, false );
                end
            end
            
            remainingtime = remainingtime - timeused;
            
            if isemptystreamline(s)
                s.endtime = simstarttime + timeused;
                if s.endtime > m.globalDynamicProps.currenttime + m.globalProps.timestep
                    xxxx = 1;
                end
                break;
            end
            
            if all(s.directionglobal==0)
                xxxx = 1;
            end
        
%             m_tubules_statistics = m.tubules.statistics
            xxxx = 1;
        end
        
%         numiters
        
        if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
            xxxx = 1;
        end
        m.tubules.tracks(si) = s;
    end
    if mod(numdots, DOTS_PER_LINE) ~= 0
        fwrite( 1, newline );
    end
    fprintf( 1, '%s: After growing streamlines, there are %d. %d steps, %d dots.\n', ...
        mfilename(), length( m.tubules.tracks ), numsteps, numdots );
    
    for si=1:length( m.tubules.tracks )
        if all(s.directionglobal==0)
            xxxx = 1;
        end
    end
    
    tracksToDelete = isemptystreamline( m.tubules.tracks );
    starttimes = [ m.tubules.tracks( tracksToDelete ).starttime ];
    endtimes = [ m.tubules.tracks( tracksToDelete ).endtime ];
    newlifetimes = [ starttimes(:), endtimes(:) ];
    if ~isfield( m.tubules.statistics, 'lifetimes' )
        m.tubules.statistics.lifetimes = zeros(0,2);
    end
    m.tubules.statistics.lifetimes = [m.tubules.statistics.lifetimes; newlifetimes];
    m.tubules.tracks = m.tubules.tracks( ~tracksToDelete );
    for i=1:length(m.tubules.tracks)
        m.tubules.tracks(i).endtime = m.globalDynamicProps.currenttime + m.globalProps.timestep;
    end
    m.tubules.statistics.died = m.tubules.statistics.died + sum( tracksToDelete );
%     m.tubules.statistics.rescue = m.tubules.statistics.rescue + numrescued;
    m.tubules.statistics.rescueinfo = [ m.tubules.statistics.rescueinfo; rescueinfo ];
    if ~isfield( m.tubules.statistics, 'severinginfo' )
        m.tubules.statistics.severinginfo = zeros(0,5);
    end
    m.tubules.statistics.severinginfo = [ m.tubules.statistics.severinginfo; severinginfo ];
    if interrupted
        ok = false;
    end
    if ~isempty(severinginfo)
        xxxx = 1;
    end
    
    oks = validStreamline( m, m.tubules.tracks );
    if any(oks)
        fprintf( 1, '%s: %d invalid streamlines.\n', mfilename(), sum(~oks) );
    end
end

function newState = randomFlip( currentState, pOnToOff, pOffToOn, dt ) %#ok<DEFNU>
%newState = randomFlip( currentState, pOn, pOff, dt )
%   A switch event takes place at constant probability per unit time of
%   pOnToOff if currentState is true, and pOffToOn if currentState is
%   false. If at least one such event takes place in time dt, return the
%   switched state.
%
%   We ignore the possibility of two or more events.

    newState = currentState;
    if newState
        if rand(1) < 1 - exp( -pOnToOff * dt )
            newState = false;
        end
    else
        if rand(1) < 1 - exp( -pOffToOn * dt )
            newState = true;
        end
    end
end

