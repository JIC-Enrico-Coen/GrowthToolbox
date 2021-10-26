function [m,plotinfo,plotonly] = leaf_plotoptions( m, varargin )
%[m,plotinfo,plotonly] = leaf_plotoptions( m, ... )
%   Set the plotting options.
%   There are many options.
%
%   leaf_plotoptions resolves all inconsistencies among the options given
%   and the options already present in m, and stores the resulting set of
%   options into m.  leaf_plot calls leaf_plotoptions, computes the data
%   to be plotted, and does the plotting.
%
%   The PLOTINFO and PLOTONLY output arguments are for internal use and
%   should be ignored.
%
%   Equivalent GUI operation:  Various options may be individually set in
%   the GUI, especially the "Plot options" panel.
%
%   See also: leaf_plot.
%
%   Topics: Plotting.

global gPlotOptionNames gABfields gPlotPriorities gAxisNames

    plotinfo = struct();
    plotonly = [];

    % Sanity check.
    if isempty(m), return; end

    % Ensure the globals we need have been set up.
    setGlobals();

    % Discard any invalid picture handles from m.
    m.pictures = m.pictures( ishandle( m.pictures ) );
    
    % Save the current plot options.  If any of them change, we need to
    % save the static part of the mesh.
    oldplotdefaults = m.plotdefaults;

    % The first optional argument may be a structure.  If so, use it.
    if ~isempty(varargin) && isstruct( varargin{1} )
        s = varargin{1};
        varargin = {varargin{2:end}};
    else
        s = struct();
    end
    
    % The remaining optional arguments specify a structure as a sequence of
    % name/value pairs.
    [s1,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end

    % The name/value pairs override whatever was specified in the first struct,
    % if there was one.
    s = setFromStruct( s, s1 );
    
    % Some options are for specifying that only a part of the mesh data are
    % to be plotted.  These are never stored in the mesh and need to be
    % separated out from those that are.
    if isfield( s, 'PLOTONLY' )
        plotonlylist = regexprep( s.PLOTONLY, '^ +', '' );
        plotonlylist = regexprep( plotonlylist, ' +$', '' );
        plotonlylist = splitString( ' +', plotonlylist );
        for i=1:length(plotonlylist)
            plotonly.(plotonlylist{i}) = true;
        end
        s = rmfield( s, 'PLOTONLY' );
    end
    
    
    % If s is empty, return.  We assume that the options already in m are
    % already consistent.
    % Or maybe we don't assume that.
    if false && isempty( fieldnames(s) )
        return;
    end
    
    % The 'hiresdpi' option is obsolete, replaced by 'hiresmagnification'.
    if isfield( s, 'hiresdpi') && ~isfield( s, 'hiresmagnification' )
        s.hiresmagnification = s.hiresdpi/72.0;
        s = rmfield( s, 'hiresdpi' );
    end
    
    [ok,s] = checkcommandargs( mfilename(), s, 'only', gPlotOptionNames{:} );
    
    % Wherever s is explicitly empty, that overrides m.
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        if isempty( s.(fn) )
            m.plotdefaults.(fn) = s.(fn);
        end
    end
    
    % Set all missing values to empty.
    missingfields = ~isfield( s, gPlotOptionNames );
    for i=1:length(missingfields)
        if missingfields(i)
            s.(gPlotOptionNames{i}) = [];
        end
    end
    
    unprocessedFields = struct();
    for i=1:length(gPlotOptionNames)
        unprocessedFields.(gPlotOptionNames{i}) = 1;
    end
    
    needSetView = false;
    % Reconcile the view parameters.
    [haveOurViewParams,ourViewParams,haveMatlabViewParams,matlabViewParams,s] = ...
        getViewParams( s );
    % Add in the unchanged view parameters from m.
    ourViewParams = defaultFromStruct( ourViewParams, m.plotdefaults.ourViewParams );
    % Reconcile all of these sources of view parameters.
    if haveMatlabViewParams
        if haveOurViewParams
            matlabViewParams = defaultFromStruct( matlabViewParams, ...
                                   cameraParamsFromOurViewParams( ourViewParams ) );
        else
            matlabViewParams = defaultFromStruct( matlabViewParams, ...
                                   m.plotdefaults.matlabViewParams );
        end
        ourViewParams = ourViewParamsFromCameraParams( matlabViewParams );
    else
        matlabViewParams = cameraParamsFromOurViewParams( ourViewParams );
    end
    if haveOurViewParams || haveMatlabViewParams
        needSetView = true;
    end

    s.ourViewParams = ourViewParams;
    s.matlabViewParams = matlabViewParams;
    markProcessed( 'ourViewParams', 'matlabViewParams' );

    s = defaultMultipleFromStruct( s, m.plotdefaults, 'axisRange', 'autoScale' );
    s = defaultEmptyFromStruct( s, m.plotdefaults, 'autozoom', 'autocentre' );
    markProcessed( 'axisRange', 'autoScale', 'autozoom', 'autocentre' );

    s = defaultEmptyFromStruct( s, m.plotdefaults, ...
            'defaultmultiplottissue', 'defaultmultiplottissueA', 'defaultmultiplottissueB' );
    
    if allABempty( s, gPlotPriorities{:} )
        % If s does not specify anything to be plotted, use whatever m
        % specifies.
        s = copyABvalues( s, m.plotdefaults );
    else
        % If s does specify something to be plotted, ignore whatever m
        % specifies.
        m.plotdefaults = setEmptyABvalues( m.plotdefaults );
    end
    
    % Apply priorities among the options that choose quantities to be plotted.
    s = applyABpriorities( s, gPlotPriorities{:} );
    s = applyABpriorities( s, 'outputaxes', 'perelementaxes' );
    
    for x = {'','A','B'}
        fn = x{1};
        oqfn = ['outputquantity', fn];
        oafn = ['outputaxes', fn];
        haveoq = ~isempty( s.(oqfn) );
        haveoa = ~isempty( s.(oafn) );
        if haveoq
            if haveoa
                % Nothing.
            else
                s.(oafn) = m.plotdefaults.(oafn);
                if isempty( s.(oafn) )
                    s.(oafn) = 'total';
                end
            end
        else
            if haveoa
                if ischar( s.(oafn) )
                    s.(oafn) = [];
                else
                    % User has explicitly given a set of axes for each finite element.
                    % m.plotdefaults.(fn_outputaxes) should be a 3*K*N array, where
                    % there are N finite elements, and K is the number of axes provided
                    % per finite element.
                    sizeoa = size( s.(oafn) );
                    if (sizeoa(1) ~= 3) ...
                            || (length(sizeoa) ~= 3) ...
                            || (sizeoa(3) ~= size(m.tricellvxs,1))
                        % user error
                        fprintf( 1, '** Wrong size of array for %s option: expected 3*K*%d, found ', ...
                            fn_outputaxes, size(m.tricellvxs,1) );
                        fprintf( 1, '%d', sizeoa(1) );
                        fprintf( 1, ' %d', sizeoa(2:end) );
                        fprintf( 1, '.\n' );
                        beep;
                        s.(oafn) = [];
                    end
                end
            else
                % Nothing.
            end
        end
    end
    
    % Handle the set of axes to be drawn.
    for x = {'','A','B'}
        axesfn = [ 'axesdrawn', x{1} ];
        if ~isempty( s.(axesfn) )
            if iscell( s.(axesfn) )
            elseif ischar( s.(axesfn) )
                names = splitString( '\s+', lower(s.(axesfn)) );
                goodnames = {};
                for i=1:length(names)
                    ni = names{i};
                    if isfield( gAxisNames, ni )
                        goodnames{ end+1 } = ni;
                    end
                end
                s.(axesfn) = goodnames;
            else
                s.(axesfn) = [];
            end
        end
    end
    
    % Normalise morphogen arguments to lists of names.  This also
    % eliminates non-existent morphogens (which could happen if morphogens
    % have been deleted).
    s.morphogen = FindMorphogenName( m, s.morphogen );
    s.morphogenA = FindMorphogenName( m, s.morphogenA );
    s.morphogenB = FindMorphogenName( m, s.morphogenB );

    % Normalise cellbodyvalue.
    s.cellbodyvalue = FindCellFactorName( m, s.cellbodyvalue );

    % Mark all AB fields as done.
    for i=1:length(gABfields)
        fn = gABfields{i};
        markProcessed( fn, [fn,'A'], [fn,'B'] );
    end

    % If something is being plotted on both sides then thick defaults to
    % true, but if thick was given as false, then the A and B options
    % are eliminated.
    plotinfo.haveplot = false;
    plotinfo.haveAplot = false;
    plotinfo.haveBplot = false;
    for i=1:(length(gPlotPriorities)-1)
        fn = gPlotPriorities{i};
        plotinfo.haveplot = plotinfo.haveplot || ~isempty( s.(fn) );
        plotinfo.haveAplot = plotinfo.haveAplot || ~isempty( s.([fn,'A']) );
        plotinfo.haveBplot = plotinfo.haveBplot || ~isempty( s.([fn,'B']) );
    end
    if isempty( s.thick )
        if plotinfo.haveAplot && plotinfo.haveBplot
            s.thick = true;
        end
    elseif ~s.thick
%         for i=1:length(gABfields)
%             fn = gABfields{i};
%             fnA = [ fn, 'A' ];
%             fnB = [ fn, 'B' ];
%             if ~isempty( s.(fn) )
%                 s.(fnA) = [];
%                 s.(fnB) = [];
%             elseif ~isempty( s.(fnA) )
%                 s.(fn) = s.(fnA);
%                 s.(fnA) = [];
%                 s.(fnB) = [];
%             elseif ~isempty( s.(fnB) )
%                 s.(fn) = s.(fnB);
%                 s.(fnA) = [];
%                 s.(fnB) = [];
%             end
%         end
%         plotinfo.haveplot = plotinfo.haveplot || plotinfo.haveAplot || plotinfo.haveBplot;
%         plotinfo.haveAplot = false;
%         plotinfo.haveBplot = false;
    end
    s = defaultEmptyFromStruct( s, m.plotdefaults, 'thick' );
    markProcessed( 'thick' );

    % Reconcile crange and autoColorRange.
    s = defaultEmptyFromStruct( s, m.plotdefaults, 'crange', 'autoColorRange' );
    % If crange is specified, it overrides autoColorRange.  NO IT DOESNT.
%     if ~isempty( s.crange ) && ~isempty( s.crange )
%         s.autoColorRange = false;
%     end
    markProcessed( 'crange', 'autoColorRange' );
    
    if ~isempty( s.cmap )
        s.cmaptype = 'custom';
    end

    % Reconcile cmaptype, cmap, and monocolors.
    s = defaultMultipleFromStruct( s, m.plotdefaults, 'cmap', 'cmaptype', 'monocolors' );
    if strcmp( s.cmaptype, 'custom' ) && isempty( s.cmap )
        % If cmaptype is custom but there is no cmap, set cmaptype to blank.
        s.cmaptype = 'blank';
    end
    % If the cmap is 'rainbow', 'custom', or 'blank', then monocolors is ignored.
    switch s.cmaptype
        case { 'rainbow', 'custom', 'blank' }
            s.monocolors = [];
        otherwise
            % Nothing.
    end
    if isempty( s.cmap ) && isempty( s.cmaptype )
        s.cmaptype = 'rainbow';
    end

    markProcessed( 'cmaptype', 'cmap', 'monocolors' );
    
    s = defaultEmptyFromStruct( s, m.plotdefaults, ...
            'outputaxes', 'outputaxesA', 'outputaxesB', ...
            'perelementaxes', 'perelementaxesA', 'perelementaxesB', ...
            'perelementcomponents', 'perelementcomponentsA', 'perelementcomponentsB' );
    if isempty( s.outputaxes )
        s.outputaxes = '';
    end
    if isempty( s.outputaxesA )
        s.outputaxesA = '';
    end
    if isempty( s.outputaxesB )
        s.outputaxesB = '';
    end
    
    % If the bio line thickness or color have been specified, copy them to
    % the first indexed edge properties. 
    if isfield( s, 'bioAlinesize' ) && ~isempty( s.bioAlinesize );
        m.secondlayer.indexededgeproperties(1).LineWidth = s.bioAlinesize;
    else
        s.bioAlinesize = m.plotdefaults.bioAlinesize;
    end
    if isfield( s, 'bioAlinecolor' ) && ~isempty( s.bioAlinecolor );
            m.secondlayer.indexededgeproperties(1).Color = s.bioAlinecolor;
    else
        s.bioAlinecolor = m.plotdefaults.bioAlinecolor;
    end
    % If the bio new line thickness or color have been specified, copy them
    % to the first indexed edge properties. 
    if isfield( s, 'bioAnewlinesize' ) && ~isempty( s.bioAnewlinesize );
            m.secondlayer.indexededgeproperties(2).LineWidth = s.bioAnewlinesize;
    else
        s.bioAnewlinesize = m.plotdefaults.bioAnewlinesize;
    end
    if isfield( s, 'bioAnewlinecolor' ) && ~isempty( s.bioAnewlinecolor );
            m.secondlayer.indexededgeproperties(2).Color = s.bioAnewlinecolor;
    else
        s.bioAnewlinecolor = m.plotdefaults.bioAnewlinecolor;
    end
    
    % Default all remaining options from m.plotdefaults.
    fns = fieldnames(unprocessedFields);
    s = defaultEmptyFromStruct( s, m.plotdefaults, fns{:} );
    
    % Calculate 
    
    % Store the options back into m.
    m.plotdefaults = s;
    
    
    
    % Establish the axis range.
    
    bboxAxisRange = meshbbox( m, true, 0.2 );
    
    if (~isempty( s.autoScale ) && s.autoScale) || isempty( s.axisRange )
        axisRange = bboxAxisRange;
    else
        axisRange = s.axisRange;
    end
    % Sanity-check the axis range: if the range along any axis is not
    % positive, replace that axis by the default bounding box range.
    for i=1:2:5
        j = i+1;
        if axisRange(i) >= axisRange(j)
            % The bboxAxisRange is always nonzero in all dimensions.
            axisRange([i j]) = bboxAxisRange( [i j] );
        end
    end
    % Store the axis range back into plotdefaults.
    m.plotdefaults.axisRange = axisRange;
    
    if s.autozoom || s.autocentre
        matlabViewParams = autozoomcentre( matlabViewParams, axisRange, ...
                                           s.autozoom, s.autocentre );
        ourViewParams = ourViewParamsFromCameraParams( matlabViewParams );
        m.plotdefaults.ourViewParams = ourViewParams;
        m.plotdefaults.matlabViewParams = matlabViewParams;
        needSetView = true;
    end
    
    % Some options take immediate effect:
    %   setting the camera view
    %   changing the axis range
    %   showing/hiding the legend, scalebar, and colorbar
    if ~isempty( m.pictures )
        for i=1:length(m.pictures)
%             fig = m.pictures(i);
%             ph = guidata( fig );
%             picture = ph.picture;
%             axisRange = unionBbox( axisRange, visibleBbox( m.pictures(i) ) );
            setaxis( m.pictures(i), axisRange, false );
        end

        if needSetView
            setViewFromMesh( m );
        end
        
        handles = guidata( m.pictures(1) );
        if isfield( handles, 'colorbar' ) && ishandle( handles.colorbar )
            if s.drawcolorbar
                drawColorbar( handles.colorbar );
%                 drawColorbar( handles.colorbar, ...
%                     getColorBarLabels(), ...
%                     m.plotdefaults.cmap, ...
%                     m.plotdefaults.crange, ...
%                     m.plotdefaults.cmaptype,...
%                     get( handles.picture, 'Color' ) );
            else
                blankColorBar( handles.colorbar, get( handles.picture, 'Color' ) );
            end
        end
        
        if isfield( handles, 'scalebar' ) && ishandle( handles.scalebar )
            if s.drawscalebar
                set( handles.scalebar, 'Visible', 'on' );
            else
                set( handles.scalebar, 'Visible', 'off' );
            end
        end
        
        if isfield( handles, 'legend' ) && ishandle( handles.legend )
            if s.drawlegend && ~isempty( get(handles.legend,'String') )
                set( handles.legend, 'Visible', 'on' );
            else
                set( handles.legend, 'Visible', 'off' );
            end
        end
    end
    
    if ~equalAnyType( m.plotdefaults, oldplotdefaults )
        saveStaticPart( m );
    end
    
    
function markProcessed( varargin )
    unprocessedFields = rmfield( unprocessedFields, varargin );
end

end

function s = applyABpriorities( s, varargin )
    for i=1:(length(varargin)-1)
        fn1 = varargin{i};
        fn1A = [ fn1, 'A' ];
        fn1B = [ fn1, 'B' ];
        for j=(i+1):length(varargin)
            fn2 = varargin{j};
            fn2A = [ fn2, 'A' ];
            fn2B = [ fn2, 'B' ];
            s = overridefield( s, ...
                       fn1A, fn2A, ...
                       fn1B, fn2B, ...
                       fn1, { fn1A, fn1B, fn2, fn2A, fn2B } );
        end
    end
end

function a = allABempty( s, varargin )
    for i=1:length(varargin)
        fn = varargin{i};
        if ~isempty( s.(fn) ) || ~isempty( s.([fn,'A']) ) || ~isempty( s.([fn,'B']) )
            a = false;
            return;
        end
    end
    a = true;
end

function s = safeSetFromStruct( s, t, varargin )
    for i = 1:length(varargin)
        fn = varargin{i};
        if isfield( t, fn )
            s.(fn) = t.(fn);
        else
            s.(fn) = [];
        end
    end
end

function s = copyABvalue( s, s1, fn )
    s = safeSetFromStruct( s, s1, fn, [fn,'A'], [fn,'B'] );
end

function s = copyABvalues( s, s1 )
    global gPlotPriorities
    for i=1:length(gPlotPriorities)
        s = copyABvalue( s, s1, gPlotPriorities{i} );
    end
end

function s = setEmptyABvalues( s )
    global gABfields
    for i=1:length(gABfields)
        fn = gABfields{i};
        s.(fn) = [];
        s.([fn 'A']) = [];
        s.([fn 'B']) = [];
    end
end

function s = defaultMultipleFromStruct( s, d, varargin )
% If every field of d is either missing or empty in s, then copy all those
% fields from d to s.
    for i=1:length(varargin)
        fn = varargin{i};
        if ~isempty( s.(fn) )
            return;
        end
    end
    for i=1:length(varargin)
        fn = varargin{i};
        s.(fn) = d.(fn);
    end
end

function s = defaultEmptyFromStruct( s, d, varargin )
% For each field in d, copy it to s if it is either missing or empty in s.
    for i = 1:length(varargin)
        fn = varargin{i};
        if ~isfield( s, fn ) || isempty( s.(fn) )
            s.(fn) = d.(fn);
        end
    end
end

