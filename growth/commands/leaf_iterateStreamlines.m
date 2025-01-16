function [m,ok] = leaf_iterateStreamlines( m )
%m = leaf_iterateStreamlines( m )
%   Create new streamlines and develop all of the streamlines for one time step.

    ok = true;
    VERBOSE = false;
    if ~m.globalProps.enabletubules
        return;
    end
    
    m = invokeIFcallback( m, 'PreTubules' );
    
    m = recalcStreamlineGlobalData( m );

    [arealTubuleDensity,~,~,~] = tubuleDensity( m );
    if m.tubules.tubuleparams.max_mt_density==0
        maxDensityFraction = 1;
    else
        maxDensityFraction = trimnumber( 0, arealTubuleDensity/m.tubules.tubuleparams.max_mt_density, 1 );
    end
    if m.tubules.tubuleparams.min_mt_density==0
        minDensityFraction = Inf;
    else
        minDensityFraction = max( 1, arealTubuleDensity/m.tubules.tubuleparams.min_mt_density );
    end
    MAX_MINDENSITYFRACTION = Inf; % 100;
    minDensityFraction = min( minDensityFraction, MAX_MINDENSITYFRACTION );
    
    m.tubules.tubuleparams.plus_catastrophe_scaling = min( m.tubules.tubuleparams.max_plus_catastrophe_scaling, ...
                                                           1/(cos(maxDensityFraction * (pi/2)) ^ m.tubules.tubuleparams.density_max_cat_sharpness) );
    if isnan( m.tubules.tubuleparams.density_max_branch_sharpness ) || (maxDensityFraction==0)
        m.tubules.tubuleparams.density_branch_scaling = 1;
    else
        m.tubules.tubuleparams.density_branch_scaling = 1 - maxDensityFraction^m.tubules.tubuleparams.density_max_branch_sharpness;
    end
    timedFprintf( '\n    density ratio %g\n    plus_catastrophe_scaling %g (max %g)\n    density_branch_scaling %g\n', ...
        maxDensityFraction, ...
        m.tubules.tubuleparams.plus_catastrophe_scaling, ...
        m.tubules.tubuleparams.max_plus_catastrophe_scaling, ...
        m.tubules.tubuleparams.density_branch_scaling );
    
    xxxx = 1;
    
    dt = m.globalProps.timestep;
    m = doTubuleBranching( m, dt );
    m = doTubuleCreation( m, dt );
    
    if isempty( m.tubules.tracks )
        m = invokeIFcallback( m, 'PostTubules' );
        return;
    end
    
    numrescued = 0;
    rescueinfo = zeros(0,5);
    numsevered = 0;
    severinginfo = zeros(0,5);
    
    % Perform all pending events that have fallen due.
    % Note that for historical reasons, the structure that records these is
    % called "severances", even though it also records other sorts of
    % events besides severances.
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
        perm_m = perm;
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
                        branchSides = randSign(1,1);
                        UNIFORM_CROSSOVER_BRANCHING = getModelOption( m, 'crossover_branch_uniform' );
                        if UNIFORM_CROSSOVER_BRANCHING
                            branchAngles = getMTBranchingAngles( m, 1, 'crossover' );
                        else
                            branchAngles = getMTBranchingAngles( m, 1, 'free' );
                        end
                        [m,newbranchinfo,newmtindexes] = spawnBranches( m, si, sevs(sevpi).vertex, [1 0], ...
                                sevs(sevpi).time - m.globalDynamicProps.currenttime, ...
                                branchSides, branchAngles );
                        % newbranchinfo is a 6-element array whose
                        % components are:
                        % newbranchinfo(1) the finite element
                        % newbranchinfo(2:4) barycentric coords of a point
                        % in the element
                        % newbranchinfo(5) 1 + Steps(m)
                        % newbranchinfo(6) branching angle.
%                         sevs(sevpi).eventtype = 'x';
                        for ti=1:newmtindexes
                            m.tubules.tracks(ti).status.interactiontime = m.tubules.tubuleparams.branch_interaction_delay;
                        end
    
                        % Update stats.
%                         if ~isfield( m.tubules.statistics, 'xoverbranchings' )
%                             m.tubules.statistics.xoverbranchings = 0;
%                         end
%                         m.tubules.statistics.xoverbranchings = m.tubules.statistics.xoverbranchings + grantednum;
                        oldStatsWidth = size(m.tubules.statistics.xoverbranchinfo,2);
                        newStatsWidth = size(newbranchinfo,2);
                        if oldStatsWidth < newStatsWidth
                            m.tubules.statistics.xoverbranchinfo( :, (oldStatsWidth+1):newStatsWidth ) = NaN;
                        end
                        newbranchinfo(6) = newbranchinfo(6) - sevs(sevpi).angleoffset; % OR SHOULD IT BE ADDED?
                        m.tubules.statistics.xoverbranchinfo = [ m.tubules.statistics.xoverbranchinfo; newbranchinfo ];
%                         if (si > length( m.tubules.tracks )) ...
%                                 || (sevi > length( m.tubules.tracks(si).status.severance )) ...
%                                 || ~compareStructs( sevs(sevpi), m.tubules.tracks(si).status.severance(perm_m(sevi)) )
%                             xxxx = 1;
%                         end
%                         if m.tubules.tracks(si).status.severance(perm_m(sevi)).eventtype ~= 'b'
%                             xxxx = 1;
%                         end
%                         m.tubules.tracks(si).status.severance(perm_m(sevi)).eventtype = 'x';
                    end
                    
                case 's'
                    % Severance.
                    catfronttail = rand(1) < m.tubules.tubuleparams.prob_crossover_cut_fronttailcat;
                    catrearhead = (rand(1) < m.tubules.tubuleparams.prob_crossover_cut_rearheadcat) || (requestMTcreation( m, 1 )==0);
%                     rescuerearhead = (rand(1) < m.tubules.tubuleparams.prob_crossover_cut_rearheadrescue) && (requestMTcreation( m, 1 )==1);
%                     catrearhead = ~rescuerearhead;
                    [mtrear,mtfront] = splitMT( m, mt, sevs(sevpi).vertex, catrearhead, catfronttail );
                    if isempty( mtfront )
                        mtrear.status.severance(sevpi) = [];
                        deltasev = length(mtrear.status.severance) - length(mt.status.severance);
                    else
                        m.tubules.maxid = m.tubules.maxid+1;
                        mtfront.id = m.tubules.maxid;
                        deltasev = length(mtrear.status.severance) + length(mtfront.status.severance) - length(mt.status.severance);
                        m.tubules.tracks(end+1) = mtfront;
%                         if rescuerearhead
%                             % Rescue the tail end.
%                             % Potential problem: will the rescued tubule
%                             % immediately collide with the other tubule?
%                             xxxx = 1;
%                             [m,mtrear] = rescueTubuleAtHead( m, mtrear );
%                             xxxx = 1;
%                         end
                        m.tubules.tracks(si) = mtrear;
                        
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
                    mt = mtrear;
                    newnumsevs = getNumberOfSeverances( m );
                    if newnumsevs > oldnumsevs
                        timedFprintf( 1, 'Error: after processing severances, there are %d new severances.\n', newnumsevs - oldnumsevs );
                        xxxx = 1;
                    end
                    
                case 'c'
                    % Crossover (without branching or severance).
                    % Ignore.
                    xxxx = 1;
                
                case { 'B', 'S' }
                    % Expired branching or severance event. Ignore.
                    xxxx = 1;
                
                otherwise
                    timedFprintf( 1, 'Unknown pending event type ''%s''.\n', sevs(sevpi).eventtype );
                    xxxx = 1;
            end
            if isempty( sevs(sevpi).vertex )
                xxxx = 1;
            end
            if sevpi > length(sevs)
                xxxx = 1;
            end
%             sevs(sevpi).eventtype = 'x';
%             if sevi > length( m.tubules.tracks(si).status.severance )
%                 xxxx = 1;
%             end
%             m.tubules.tracks(si).status.severance(sevi).eventtype = sevs(sevpi).eventtype;
        end
    end
    
    % Remove all expired events.
    for si=1:length( m.tubules.tracks )
        sevs = [m.tubules.tracks(si).status.severance];
        if ~isempty( sevs )
            expired = [sevs.time] <= m.globalDynamicProps.currenttime;
%             expired = [sevs.eventtype] == 'x';
%             if any( expired )
%                 xxxx = 1;
%             end
            for svi=1:length(expired)
                if expired(svi)
                    m.tubules.tracks(si).status.severance(svi).eventtype = ...
                        upper( m.tubules.tracks(si).status.severance(svi).eventtype );
                end
            end
%             m.tubules.tracks(si).status.severance( expired ) = [];
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
        fprintf( 1, '%s: After processing severances, there are %d streamlines. %d tubule growth steps, %d dots.\n', ...
            mfilename(), length( m.tubules.tracks ), numsteps, numdots );
    end
    numsteps = 0;
    numdots = 0;
    
%     npsafter = getNumberOfSeverances( m );
    % May want to report oldnumsevs and npsafter.
    xxxx = 1;
    if interrupted
        ok = false;
        m = invokeIFcallback( m, 'PostTubules' );
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
    
        MAXITERS = 51;
        numiters = 0;
        remainingtime = dt - (simstarttime - m.globalDynamicProps.currenttime);
        ok1 = true;
        if s.id==215
            xxxx = 1;
        end
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
            paramsneeded = { 'plus_shrinkrate', ...
                             'prob_plus_rescue', ...
                             'prob_crossover_rescue', ...
                             'rescue_angle_mean', ...
                             'rescue_angle_spread', ...
                             'plus_growthrate', ...
                             'plus_shrinkrate', ...
                             'minus_catshrinkrate', ...
                             'minus_shrinkrate' };
            params = getTubuleParamsModifiedByMorphogens( m, s, paramsneeded );
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
                    
                    NEW_RESCUE = true;
                    if NEW_RESCUE
                        % Rescuing always requires creating a new growing head.
                        % See if we would get one.
                        no_Rescue = requestMTcreation( m, 1 )==0;

                        % Determine the distance it will shrink in the
                        % remaining time if no rescue happens.
                        maxshrink = remainingtime * params.plus_shrinkrate;

                        % Find the cumulative lengths of the segments from the
                        % head back to the tail, and the corresponding vertex
                        % indexes.
                        cumextseglengths = [ 0 cumsum( s.segmentlengths(end:-1:1) ) ];
                        segindexes = length(s.segmentlengths):-1:1;


                        % Record the exact place where the maximum shrink ends.
                        % This is how far the tubule will shrink in the
                        % period of remaining time if there is no rescue.
                        % 
                        maxshrinkextseg = find( cumextseglengths > maxshrink, 1 );
                        if isempty(maxshrinkextseg)
                            % The tubule will shrink down to nothing (if no
                            % rescue).
                            norescue_vx = 1;
                            norescue_bc = [1 0];
                            norescue_length = cumextseglengths(end);
                        elseif maxshrinkextseg==1
                            xxxx = 1; % Should be impossible.
                        else
                            % The tubule will shrink back to a certain
                            % point (if no rescue). Trim cumseglengths and
                            % vxindexes to end at the  vertex at the start
                            % of the segment where shrinking ends.
                            maxshrinkseg = maxshrinkextseg-1;
                            norescue_vx = segindexes( maxshrinkseg );
                            norescue_frac_retained = (cumextseglengths(maxshrinkextseg) - maxshrink)/s.segmentlengths( norescue_vx );
                            norescue_bc = [ 1 - norescue_frac_retained, norescue_frac_retained ];
                            norescue_length = maxshrink;
%                             norescue_length1 = cumextseglengths( maxshrinkseg ) + (1-norescue_frac_retained)*s.segmentlengths( norescue_vx );
%                             norescue_length2 = dot( cumextseglengths( [ maxshrinkextseg maxshrinkseg ] ), norescue_bc );
                            cumextseglengths((maxshrinkextseg+1):end) = [];
                            segindexes((maxshrinkseg+1):end) = [];
                        end
                        norescue_time = norescue_length / params.plus_shrinkrate;

                        if no_Rescue
                            haveSpontaneousRescue = false;
                            haveCrossoverRescue = false;
                            timeused = norescue_time;
                        else
                            % Determine when a spontaneous rescue will happen.
                            
                            if isnan( m.tubules.tubuleparams.density_min_rescue_sharpness )
                                minDensityRescueIncrease = 1;
                            else
                                minDensityRescueIncrease = 1 + m.tubules.tubuleparams.density_min_rescue_sharpness/max( minDensityFraction - 1, 0 );
                            end
                            
                            spontaneous_rescue_time = sampleexp( params.prob_plus_rescue * minDensityRescueIncrease );
                            spontaneous_rescue_length = spontaneous_rescue_time * params.plus_shrinkrate;

                            % Look for crossover rescues.
                            % Find which of the vertexes are crossover vertexes.
                            if isempty( s.status.severance )
                                crossover_rescue_time = Inf;
                            else
                                foo = [s.status.severance.eventtype];
                                crossoverevents = foo=='c';
                                crossoverdescriptions = s.status.severance(crossoverevents);
                                crossoververtexes = [ crossoverdescriptions.vertex ];
                                isshallow = abs( [crossoverdescriptions.angleoffset] ) < m.tubules.tubuleparams.min_angle_crossover_rescue;
                                if any(isshallow)
                                    timedFprintf( 'Crossover rescue: %d of %d crossovers excluded as shallow.\n', sum(isshallow), length(crossoverdescriptions) );
                                    crossoververtexes( isshallow ) = [];
                                end
                                iscrossoververtex = false( 1, length( s.vxcellindex ) );
                                iscrossoververtex( crossoververtexes ) = true;

                                % Only keep those ones.
                                foo = iscrossoververtex(segindexes(1:(end-1)));
                                crossover_rescue_lengths = cumextseglengths(foo);
                                crossover_vxindexes = segindexes(foo);

                                % Find the first that causes a rescue, if any.
                                crossover_rescue_i = find( rand( length(crossover_rescue_lengths), 1 ) < params.prob_crossover_rescue, 1 );
                                if ~isempty(crossover_rescue_i)
                                    crossover_rescue_length = crossover_rescue_lengths( crossover_rescue_i );
                                    crossover_rescue_vx = crossover_vxindexes( crossover_rescue_i );
                                    crossover_rescue_time = crossover_rescue_length/params.plus_shrinkrate;
                                    xxxx = 1;
                                else
                                    crossover_rescue_time = Inf;
                                end
                            end

                            [timeused, rescuetype] = min( [ spontaneous_rescue_time, crossover_rescue_time, norescue_time ] );

                            haveSpontaneousRescue = rescuetype==1;
                            haveCrossoverRescue = rescuetype==2;
                            no_Rescue = rescuetype==3;
                        end
                        
                        if haveSpontaneousRescue
                            if spontaneous_rescue_length==0
                                xxxx = 1;
                            end
                            if cumextseglengths(end) <= spontaneous_rescue_length
                                % 2023 Oct 17 This should never happen, but
                                % somehow on rare occasions, shrink_bc ends up
                                % set to []. This will happen if the above
                                % holds.
                                timedFprintf( 'Abnormal condition:\n    cumextseglengths(end) <= spontaneous_rescue_length\n' );
                                xxxx = 1;
                            end
                            rescue_revextseg = find( cumextseglengths > spontaneous_rescue_length, 1 );
                            rescue_revseg = rescue_revextseg-1;
                            rescue_length = cumextseglengths(rescue_revextseg);
                            shrink_vx = segindexes( rescue_revseg );
                            segment_length_retained = rescue_length - spontaneous_rescue_length;
                            shrink_frac_retained = segment_length_retained/s.segmentlengths( shrink_vx );
                            shrink_bc = [ 1 - shrink_frac_retained, shrink_frac_retained ];
                            xxxx = 1;
                        elseif haveCrossoverRescue
                            shrink_vx = crossover_rescue_vx;
                            shrink_bc = [1 0];
                            xxxx = 1;
                        elseif no_Rescue
                            shrink_vx = norescue_vx;
                            shrink_bc = norescue_bc;
                        else
                            xxxx = 1;
                        end
                        xxxx = 1;
                        if isempty(shrink_bc)
                            xxxx = 1;
                        else
                            s = shrinkStreamlineTo( m, s, shrink_vx, shrink_bc(2), true );
                        end
                        if isemptystreamline( s )
                            m.tubules.tracks(si) = s;
                            continue;
                        end
                        if haveSpontaneousRescue || haveCrossoverRescue
                            s.status.head = 1;
                            numrescued = numrescued+1;
                            rescueinfo( numrescued, : ) = [ s.vxcellindex(end), s.barycoords(end,:), Steps(m)+1 ];

                            if isfield( params, 'rescue_angle_mean' ) && ~isempty(params.rescue_angle_mean)
                                deviation = rescueAngle( params.rescue_angle_mean, params.rescue_angle_spread );
%                                 deviation = modreflective( params.rescue_angle_mean + params.rescue_angle_spread * randn( 1 ), pi ) * randSign( 1 );
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
                        end
                    else
                        nextrescue = sampleexp( params.prob_plus_rescue );
                        if (nextrescue < remainingtime) && (requestMTcreation( m, 1 )==1)
                            % A rescued tubule may change its direction,
                            % according to the parameters rescue_angle_mean and
                            % rescue_angle_spread, if present; otherwise the
                            % original direction is maintained.
                            s.status.head = 1;
                            numrescued = numrescued+1;
                            rescueinfo( numrescued, : ) = [ s.vxcellindex(end), s.barycoords(end,:), Steps(m)+1 ];
                            timeused = nextrescue;

                            if isfield( params, 'rescue_angle_mean' ) && ~isempty(params.rescue_angle_mean)
                                deviation = rescueAngle( params.rescue_angle_mean, params.rescue_angle_spread );
%                                 deviation = modreflective( params.rescue_angle_mean + params.rescue_angle_spread * randn( 1 ), pi ) * randSign( 1 );
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
                timedFprintf( 'empty tubule found.\n' );
                s;
                xxxx = 1;
            end
    
            if headgrowth > 0
%                 s1 = s;
                [m,s,lengthgrown] = extendStreamline( m, s, headgrowth, si );
                if sum( s.segmentlengths ) < 0.001
                    xxxx = 1;
                end
                if length(s.vxcellindex)==1
                    xxxx = 1;
                end
                timeused = lengthgrown/params.plus_growthrate;
            elseif headgrowth < 0
                % Head shrinkage already performed above.
%                 slen = sum( s.segmentlengths );
%                 s = shrinkStreamlineBy( m, s, -headgrowth, true );
%                 slen2 = sum( s.segmentlengths );
%                 timeused = (slen - slen2)/params.plus_shrinkrate;
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
                    s = shrinkStreamlineBy( m, s, tailshrink, false );
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
            
            if timeused==0
                % No progress, stop. remainingtime should be negligible.
                if (oldheadstatus==1) && (remainingtime > 1e-4)
                    xxxx = 1;
                elseif (oldheadstatus==1)
                    break;
                end
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
    
    m = invokeIFcallback( m, 'PostTubules' );
end

function deviation = rescueAngle( rescue_angle_mean, rescue_angle_std )
    deviation = modreflective( rescue_angle_mean + rescue_angle_std * randn( 1 ), pi ) * randSign( 1 );
end

function [m,s] = rescueTubuleAtHead( m, s )
    % Calculate the rescue deviation angle.
    rescue_angle_mean = getTubuleParamModifiedByMorphogens( m, 'rescue_angle_mean', s );
    rescue_angle_spread = getTubuleParamModifiedByMorphogens( m, 'rescue_angle_spread', s );
    deviation = rescueAngle( rescue_angle_mean, rescue_angle_spread );

    % Calculate the new global direction.
    currentDirection = s.directionglobal;
    currentElement = s.vxcellindex(end);
    elementNormal = m.cellFrames(:,3,currentElement)';
    elementVxs = m.nodes( m.tricellvxs( currentElement, : ), : );
    newDirection = rotateVecAboutVec( currentDirection, elementNormal, deviation );

    % Convert the new global direction to directional barycentric coordinates.
    [theDirBcs,dbc_err] = baryDirCoords( elementVxs, elementNormal, newDirection );

    % Install the new direction into the tubule.
    s.directionglobal = newDirection;
    s.directionbc = theDirBcs;
    
    % Actually rescue it.
    s.status.head = 1;

    % Record the event.
    if ~isfield( m.tubules.statistics, 'rescueangles' )
        m.tubules.statistics.rescueangles = [];
    end
    m.tubules.statistics.rescueangles(end+1) = deviation;
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

