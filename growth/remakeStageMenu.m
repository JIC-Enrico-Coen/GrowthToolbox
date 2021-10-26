function handles = remakeStageMenu( handles, currentsuffix )
    if nargin < 2
        if isempty(handles.mesh)
            currentsuffix = [];
        else
            currentsuffix = handles.mesh.globalDynamicProps.laststagesuffix;
        end
    end

    global gMISC_GLOBALS
    
    % Delete everything below the Help item.
    c = get( handles.stagesMenu, 'Children' );
    for i=1:length(c)
        if strcmp( get(c(i),'Tag'), 'helpmenu_stagesMenu' )
            break;
        end
        delete( c(i) );
    end
    
    if isempty( handles.mesh )
        return;
    end

    % Add an item for the initial stage.
    itemHandle = uimenu( handles.stagesMenu, ...
        'Tag', 'itemStage_initial', ...
        'Label', 'Initial state', ...
        'Separator', 'on', ...
        'Callback', @stageMenuItemCallback );
    if isempty( currentsuffix )
        set( itemHandle, 'Checked', 'on' );
    end
    
    % Find the stage files that exist in the project directory.
    stageTimes = savedStages( handles.mesh );
    
    % Merge with handles.mesh.stagetimes.
    [handles.mesh.stagetimes,~,fromnew] = ...
        addStages( handles.mesh.stagetimes, stageTimes );

    % Convert all to strings.
    steps = stageTimeToText( handles.mesh.stagetimes );
    if ~iscell(steps)
        steps = { steps };
    end

    % Add all the new items to the Stages menu.
    numinitmenuitems = length( get( handles.stagesMenu, 'Children' ) );
    menudata = [];
    if ~isempty(steps)
        for si=1:length(steps)
            stepname = steps{si};
            itemname = suffixStringToItemString( stepname );
            if fromnew(si)
                prefix = [];
                suffix = [];
            else
                prefix = '(';
                suffix = ')';
            end
            md = struct( ...
                'Tag', ['itemStage', gMISC_GLOBALS.stageprefix, stepname], ...
                'Label', [ prefix 'Time ' itemname suffix ], ...
                'Checked', 'off', ...
                'Callback', @stageMenuItemCallback );
            if isempty( menudata )
                menudata = md;
                menudata(length(steps)+1) = md;
                menudata(end) = [];
            else
                menudata(si) = md;
            end
            if strcmp( currentsuffix, [gMISC_GLOBALS.stageprefix, stepname ] )
                menudata(si).Checked = 'on';
            end
        end
    end
    makePackedMenu( handles.stagesMenu, numinitmenuitems+1, menudata, ...
        20, 5 );
    guidata(handles.output, handles);
end
