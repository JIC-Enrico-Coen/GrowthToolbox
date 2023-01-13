function [m,ok] = leaf_iterate( m, varargin )
%[m,ok] = leaf_iterate( m, numsteps, ... )
%   Run the given number of iterations of the growth process.
%   In each iteration, the following things happen:
%       * Strains are set up in the leaf according to the effects of the
%         morphogens at each point causing the material to grow.
%       * The elasticity problem is solved to produce a new shape for the
%         leaf.
%       * Morphogens which have a nonzero diffusion coefficient are allowed 
%         to diffuse through the mesh.
%       * If dilution by growth is enabled, the amount of every morphogen
%         is diluted at each point according to how much that part of the
%         leaf grew.
%       * A user-supplied routine is invoked to model local interactions
%         between the morphogens.
%       * The layer of biological cells is updated.
%       * If requested by the options, the mesh is plotted after each
%         iteration.
%
%   Results:
%   ok: True if there was no problem (e.g. invalid arguments, a user
%   interrupt, or an error in the interaction function).  False if there
%   was.
%
%   Arguments:
%   numsteps:     The number of iterations to perform.  If this is zero,
%                 the computation will continue indefinitely or until
%                 terminated by one of the other options.
%
%   Options:
%
%   'until'       Run the simulation until this time has been reached or
%                 exceeded.  The value [] disables this option.
%   'duration'    Run the simulation until this time has elapsed since the
%                 current time, or until the first step that exceeds this
%                 time. The value [] disables this option.
%   'targetarea'  Run the simulation until the area of the canvas is at
%                 least this number times the initial area.  The value []
%                 disables this option.
%
%   If more than stopping criterion is given, the simulation stops as soon
%   as any one of them is achieved.
%
%   'plot'  An integer n.  The mesh will be plotted after every n
%           iterations.  0 means do not plot the mesh at all; -1 means plot
%           the mesh only after all the iterations have been completed.
%           The default value is 1, i.e. plot the mesh after each iteration.
%   Example:
%       m = leaf_iterate( m, 20, 'plot', 4 );
%
%   Equivalent GUI operation: clicking one of the following buttons in the
%   "Simulation" panel: "Run" (do a specified number of steps), "Step" (do
%   one step), or "Run to..." (run until the area has increased by a
%   specified factor).
%
%   Topics: Simulation.

%m = recordframe( m );
%beep;
%return;

% Steps in each cycle:
%   * Invoke interaction function.
%   * Perform diffusion (taking account of clamped values).
%   * Perform decay.  (This would be better built into the diffusion
%         calculation.)
%   * Restore clamped values.
%   * Calculate the polarisation gradients.
%   * Perform a FEM calculation.
%   * Generate the FEM cell normal vectors.
%   * Split large FEM cells.
%   * Recalculate FEM cell areas.
%   * Recalculate the second layer global positions and split large
%     second layer cells.

    ok = true;
    if isempty(m), return; end
    
    if nargin < 2
        numsteps = 1;
        args = {};
    elseif ischar(varargin{1})
        numsteps = [];
        args = varargin;
    else
        [ok, numsteps, args] = getTypedArg( mfilename(), 'numeric', varargin );
        if ~ok, return; end
        numsteps = floor(numsteps);
    end
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultfields( s, 'plot', 1, 'until', [], 'duration', [], 'targetarea', [] );
    ok = checkType( mfilename(), 'numeric', s.plot );
    if ~ok, return; end
    s.plot = floor(s.plot);
    ok = checkcommandargs( mfilename(), s, 'only', ...
            'plot', 'until', 'duration', 'targetarea' );
    if ~ok, return; end
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m, false );
    if ~ok, return; end
    if isempty( numsteps )
        if isempty( s.until ) && isempty( s.duration ) && isempty( s.targetarea )
            numsteps = 1;
        else
            numsteps = Inf;
        end
    end
    starttime = m.globalDynamicProps.currenttime;
    
    full3d = usesNewFEs( m );

    m = invalidateLineage( m );
    
    timedFprintf( 1, 'About to perform %d iterations.\n', numsteps );

    step = 1;
    interrupted = false;
    plotted = false;
    while ok && ~interrupted && ~finished( m, step, numsteps, s.until, starttime, s.duration, s.targetarea )
        if teststopbutton(m)
            ok = false;
            break;
        end
        startTime = cputime;
        starttic = tic;
        timedFprintf( 1, 'Starting iteration %d, time %.3f.\n', ...
        	m.globalDynamicProps.currentIter+1, m.globalDynamicProps.currenttime );
        timedFprintf( 2, 'Starting iteration %d, time %.3f.\n', ...
        	m.globalDynamicProps.currentIter+1, m.globalDynamicProps.currenttime );
        if teststopbutton(m)
            ok = false;
            break;
        end
        m = calcPolGrad( m );
        m = makeCellFrames( m );
        if ~m.globalProps.flatten
            if m.globalProps.allowInteraction
                [m,ok] = attemptInteractionFunction( m ); %, handles );
                if ~ok, break; end
            else
                timedFprintf( 1, 'Interaction function disabled.\n' );
            end
        end
        m = disallowNegativeGrowth( m );
        if ~m.globalProps.flatten
            if m.globalProps.diffusionEnabled
                m = diffusegrowth( m );
                nondiffusibles = ~isDiffusible( m );
            else
                nondiffusibles = 1:size(m.morphogens,2);
            end
            for i=nondiffusibles(:)'
                nonclamped = m.morphogenclamp(:,i) < 1;
%                 m.morphogens(nonclamped,i) = m.morphogens(nonclamped,i) ...
%                     + m.globalProps.timestep * ( ...
%                         m.mgen_production(nonclamped,i) ...
%                         - m.morphogens(nonclamped,i) .* m.mgen_absorption(nonclamped,i) ...
%                       );
                m.morphogens(nonclamped,i) = ...
                    m.morphogens(nonclamped,i) .* exp(- m.globalProps.timestep * m.mgen_absorption(nonclamped,i)) ...
                    + m.globalProps.timestep * m.mgen_production(nonclamped,i);
            end
        end
        m = calcPolGrad( m );
        if teststopbutton(m)
            ok = false;
            break;
        end
        
        [m,ok] = leaf_iterateStreamlines( m );
        if ~ok
            return;
        end
        
        stepstarttime = m.globalDynamicProps.currenttime;
        if isfield( m.secondlayer, 'edgeattriblength' ) && any( m.secondlayer.edgeattriblength==0 )
            xxxx = 1;
        end
        m.secondlayer.edgeattriblength = celledgelengths(m);
        if any( m.secondlayer.edgeattriblength==0 )
            xxxx = 1;
        end
        [m,ok,splitdata] = onestep( m, m.globalProps.useGrowthTensors, m.globalProps.useMorphogens );
        m.globalDynamicProps.currentIter = m.globalDynamicProps.currentIter + 1;
        m.globalDynamicProps.currenttime = ...
            m.globalDynamicProps.currenttime + m.globalProps.timestep;
        if ~isempty(handles)
            if m.globalDynamicProps.currentIter==1
                enableMutations( handles, 'off' );
            end
            if testAndClear( handles.plotFlag )
                timedFprintf( 1, 'Change (plot) flag detected during iteration %d.\n', ...
                    m.globalDynamicProps.currentIter );
                m = getPlotOptionsFromDialog( m, handles );
            end
            c = get( handles.commandFlag, 'UserData' );
            set( handles.commandFlag, 'UserData', struct([]) );
            if ~isempty(c)
                timedFprintf( 1, 'User commands detected during iteration %d.\n', ...
                    m.globalDynamicProps.currentIter );
                m = executeCommands( m, c, false, handles );
            end
            if teststopbutton(m)
                interrupted = true;
            end
        end
        m = calculateOutputs( m );

        % Rotate growth tensors
        if full3d
            fevxspos = m.FEnodes;
            fevxs = m.FEsets(1).fevxs;
            numcells = size( fevxs, 1 );
        else
            fevxspos = m.prismnodes;
            tcv = m.tricellvxs*2;
            fevxs = [ tcv-1, tcv ];
            numcells = size(m.tricellvxs,1);
        end
        if ~isempty(m.displacements)
            for i=1:numcells
                newpos = fevxspos( fevxs(i,:), : );
                oldpos = newpos - m.displacements( fevxs(i,:), : );
                lt = fitmat( oldpos, newpos );
                rot = extractRotation( lt );
                m.celldata(i).cellThermExpGlobalTensor = ...
                    rotateGrowthTensor( m.celldata(i).cellThermExpGlobalTensor', ...
                        rot' )';
                if ~isempty(m.directGrowthTensors)
                    m.directGrowthTensors(i,:) = ...
                        rotateGrowthTensor( m.directGrowthTensors(i,:), ...
                            rot' );
                end
            end
        end
        
        if m.globalProps.newcallbacks
            [m,~] = invokeIFcallback( m, 'Postiterate' );
        elseif isa( m.globalProps.userpostiterateproc, 'function_handle' )
            timedFprintf( 1, 'Calling user post-iterate procedure %s.\n', ...
                func2str( m.globalProps.userpostiterateproc ) );
            m = m.globalProps.userpostiterateproc( m );
        end
        m = updateValidityTime( m, stepstarttime );
        if any( m.secondlayer.edgeattriblength==0 )
            xxxx = 1;
        end
        m.secondlayer.edgeattriblength = [];
    
        % Update cell data display factors.
        if hasNonemptySecondLayer(m)
            m.secondlayer.cellidtotime( m.secondlayer.cellid, 2 ) = m.globalDynamicProps.currenttime;
            agefactor = FindCellRole( m, 'CELL_AGE' );
            if agefactor ~= 0
                m.secondlayer.cellvalues(:,agefactor) = m.secondlayer.cellidtotime( m.secondlayer.cellid, 2 ) ...
                                                        - m.secondlayer.cellidtotime( m.secondlayer.cellid, 1 );
            end
        end
        if hasNonemptySecondLayer(m)
            areafactor = FindCellRole( m, 'CELL_AREA' );
            if areafactor ~= 0
                m.secondlayer.cellvalues(:,areafactor) = m.secondlayer.cellarea;
            end
        end
        
        if isempty(handles)
            announceSimStatus( m );
        else
            handles.mesh = m;
            guidata( handles.output, handles );
            announceSimStatus( handles );
        end
        if (s.plot > 0) && (mod(step,s.plot)==0)
            if ~isempty(handles)
                handles = processPendingData( handles );
                m = handles.mesh;
            else
                m = leaf_plot( m );
            end
            wasMakingMovie = movieInProgress(m);
            if wasMakingMovie
                if m.globalProps.viewrotationperiod > 0
                    az = currentView( m );
                    if ~isempty(az)
                        newaz = normaliseAngle( ...
                            m.globalProps.viewrotationstart ...
                            + 360*m.globalDynamicProps.currenttime/m.globalProps.viewrotationperiod, ...
                            -180 );
                        m = leaf_plotoptions( m, 'azimuth', newaz );
                    end
                end
                if m.globalProps.stepsperframe > 0
                    m.globalDynamicProps.stepssinceframe = mod( m.globalDynamicProps.stepssinceframe+1, m.globalProps.stepsperframe );
                else
                    m.globalDynamicProps.stepssinceframe = 0;
                end
                if m.globalDynamicProps.stepssinceframe==0
                    m = recordframe( m );
                end
            end
            if ~isempty(handles) && (wasMakingMovie && ~movieInProgress(m))
                % Movie was closed for some reason.  Reset the label on
                % the movieButton.
                set( handles.movieButton, 'String', 'Record movie...' );
            end
            plotted = true;
        else
            plotted = false;
        end
        step = step+1;
        
        [isstagetime,stagetime] = isCurrentStage( m );
        timedFprintf( 'isstagetime %d, stagetime %g\n', isstagetime, stagetime );
        if isstagetime || m.globalProps.recordAllStages
            if (~isstagetime) && m.globalProps.recordAllStages
                timedFprintf( 1, 'Not a stage time, but recording all stages, so recording a stage at time %g.\n', m.globalDynamicProps.currenttime );
            else
                timedFprintf( 1, 'Stage time %g reached at model time %g, so recording stage file.\n', stagetime, m.globalDynamicProps.currenttime );
            end
            if isempty( m.globalProps.currentrun )
                timedFprintf( 1, 'No current run, so saving stage to project directory.\n' );
                [m,ok] = leaf_savestage( m );
            else
                currentrun = m.globalProps.currentrun;
                timedFprintf( 'Current run is ''%s''.\n', currentrun );
                if isempty(currentrun)
                    timedFprintf( 'No current run.\n' );
                else
                    fullmodeldir = getModelDir( m );
                    fullrundir = fullfile( fullmodeldir, 'runs', currentrun );
                    if ~exist( fullrundir, 'dir' )
                        timedFprintf( 'Run directory %s does not exist.\n', fullrundir );
                    else
                        timedFprintf( 1, 'Saving stage to run directory %s.\n', fullrundir );
                        fullmeshesdir = fullfile( fullrundir, 'meshes' );
                        [ok,~] = mkdir( fullmeshesdir );
                        if ok
                            [m,ok] = leaf_savestage( m, fullmeshesdir );
                        else
                            timedFprintf( 1, 'Could not create meshes dir %s.\n', fullmeshesdir );
                        end
                    end
                end
            end
            if ~ok
                timedFprintf( 1, 'Problem saving stage %f.\n', ...
                    m.globalDynamicProps.currenttime );
            end
        else
            timedFprintf( 1, 'Not saving a stage at time %g, as not a stage time and not recording all stages.\n', m.globalDynamicProps.currenttime );
        end
        
        fwrite( 1, [simStatusString(m), newline()] );
        timedFprintf( 2, 'Completed iteration %d, sim time %g.\n', ...
        	m.globalDynamicProps.currentIter, m.globalDynamicProps.currenttime );
        timedFprintf( 1, 'Completed iteration %d, sim time %g.\n', ...
        	m.globalDynamicProps.currentIter, m.globalDynamicProps.currenttime );
        m.timeForIter = cputime() - startTime;
        m.ticForIter = toc( starttic );
    end
    
    % Iterations have ended.
    
%     if m.globalProps.maxIters ~= m.globalDynamicProps.currentIter
%         m.globalProps.maxIters = m.globalDynamicProps.currentIter;
%         if ~isempty(handles)
%             announceSimStatus( handles, m );
%         end
%     end

    if (plotted == false) && ...
            ((s.plot == -1) || ((s.plot > 0) && (mod(step,s.plot) ~= 0)))
        if ~isempty(handles) && testAndClear( handles.plotFlag )
            m = getPlotOptionsFromDialog( m, handles );
        end
        m = leaf_plot( m );
        drawnow;
        m = recordframe( m );
    end
    updateGUIFromMesh( m );  % In case the interaction function changed any
                             % of the mesh properties that are displayed in
                             % the GUI.  For efficiency, we could do this
                             % only if the i.f. notifies us in some way,
                             % but since updateGUIFromMesh is just setting
                             % the contents of a couple of dozen text boxes
                             % and checkboxes, it's not worth it.
                             % Note that updateGUIFromMesh is safe to call
                             % even if this function is not being called
                             % from within GFtbox.
    ok = ok && ~interrupted;
    drawnow;
    
    m = concludeGUIInteraction( handles, m, savedstate );
    setRunning( handles, false );
end

function f = finished( m, step, numsteps, targettime, starttime, targetduration, targetarea )
    if isfield( m, 'stop' ) && m.stop
        timedFprintf( 1, 'Simulation terminated by interaction function.\n' );
        f = true;
        return;
    end
    if (numsteps > 0) && (step > numsteps)
        timedFprintf( 1, 'Simulation terminated after %d steps.\n', numsteps );
        f = true;
        return;
    end
    if ~isempty(targettime) && ((targettime - m.globalDynamicProps.currenttime) <= m.globalProps.timestep/2)
        timedFprintf( 1, 'Simulation terminated on reaching time %f.\n', targettime );
        f = true;
        return;
    end
    if ~isempty(targetduration) && ((starttime + targetduration - m.globalDynamicProps.currenttime) <= m.globalProps.timestep/2)
        timedFprintf( 1, 'Simulation terminated after duration %f at time %f.\n', targetduration, targettime );
        f = true;
        return;
    end
    if ~isempty(targetarea) && (m.globalDynamicProps.currentArea/m.globalProps.initialArea >= targetarea)
        timedFprintf( 1, 'Simulation terminated on reaching area multiple %f.\n', targetarea );
        f = true;
        return;
    end
    f = false;
end
