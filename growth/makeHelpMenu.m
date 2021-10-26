function makeHelpMenu( handles )
    helpdir = fullfile( handles.codedirectory, 'Help' );
    if ~exist( helpdir, 'dir' )
        return;
    end
    deleteMenuItems( handles.help );
    helpfiles = dirnames( helpdir );
    numhelp = 0;
    uimenu( 'Parent', handles.help, 'Label', 'Open Manual', 'Callback', @openManual_Callback );
    uimenu( 'Parent', handles.help, ...
            'Label', 'Citation (bibtex)', ...
            'UserData', struct('bibtex',1), ...
            'Callback', @citation_Callback );
    uimenu( 'Parent', handles.help, ...
            'Label', 'Citation (plain text)', ...
            'UserData', struct('bibtex',0), ...
            'Callback', @citation_Callback );
    uimenu( 'Parent', handles.help, ...
            ... % 'Label', '<HTML><body><i>Topic snippets</i></body></HTML>', ...
            'Label', 'Topic snippets', ...
            'Enable', 'off', ...
            'Separator', 'on' );
    for i=1:length(helpfiles)
        helpfile = regexprep( helpfiles{i}, '\s*$', '' );
        n = length(helpfile)-4;
        if n <= 0
            continue;
        end
        if helpfile(1)=='.'
            continue;
        end
        if ~strcmp( helpfile( (n+1):(n+4) ), '.txt' )
            continue;
        end
        helpfile = helpfile( 1:n );
        numhelp = numhelp+1;
        hm = uimenu( 'Parent', handles.help, ...
                     'Label', helpfile, ...
                     'Callback', @helpmenuItem_Callback );
    end
end

function helpmenuItem_Callback( hObject, eventData )
    helpfig = get( hObject, 'UserData' );
    if ishandle( helpfig )
        figure(helpfig);
    else
        set( hObject, 'UserData', [] );
        helpname = get( hObject, 'Label' );
        helpfig = displayHelpFile( helpname );
        set( hObject, 'UserData', helpfig );
    end
end
