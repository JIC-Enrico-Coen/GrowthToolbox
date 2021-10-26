function getHelpText( hmenu )
    MAXBINSIZE = 12;
    cmddir = fullfile( GFtboxDir(), 'growth', 'commands' );

    cmdnames = dirnames( fullfile( cmddir, '*.m' ) );
    xx = lower(cmdnames);
    [yy,perm] = sort(xx);
    cmdnames = cmdnames(perm);
    alltags = {};
    okcmdnames = {};
    allletters = char(zeros( 1, length(cmdnames) ));
    numok = 0;
    tagtocmd = struct();
    badtags = { 'OBSOLETE', 'HIDE', 'UNIMPLEMENTED' };
    for i=1:length(cmdnames)
        cmdname = regexprep( cmdnames{i}, '\.m$', '' );
        cmdfile = fullfile( cmddir, cmdname );
        fid = fopen( [cmdfile, '.m'], 'r' );
        if fid==-1
            fprintf( 1, 'Could not open %s.\n', [cmdfile, '.m'] );
            continue;
        end
        [ht,tags] = readHelpText( fid );
        fclose( fid );

        if isempty(ht)
            fprintf( 1, 'No help text for %s.\n', [cmdfile, '.m'] );
            continue;
        end

        if regexp( cmdname, '^leaf_.' )
            letter = cmdname(6);
        else
            letter = cmdname(1);
        end
        
        if haveBadTag( tags )
          % fprintf( 1, '%s is excluded.\n', cmdname );
            continue;
        end
        
        numok = numok+1;
      % fprintf( 1, '%s %s: %s\n', letter, cmdname, joinstrings( ', ', tags ) );
        alltags = { alltags{:}, tags{:} };
        allletters( numok ) = letter;
        okcmdnames{numok} = cmdname;
        if isempty(tags)
            tags = {'Misc'};
        end
        for j=1:length(tags)
            t = tagtofield( tags{j} );
            if ~isfield( tagtocmd, t )
                tagtocmd.(t) = {};
            end
            tc = tagtocmd.(t);
            tc{end+1} = cmdname;
            tagtocmd.(t) = tc;
        end
    end
    alltags = unique( alltags );
    allletters( (numok+1):end ) = '';
    
    [binsizes,bins] = alphabins( allletters, MAXBINSIZE );
    
    if nargin >= 1
        uimenu( 'Parent', hmenu, ...
                ... % 'Label', '<HTML><body><i>Commands (alpha)</i></bodyd</HTML>', ...
                'Label', 'Commands (alpha)', ...
                'Enable', 'off', ...
                'Separator', 'on' );
        binstart = 1;
        for i=1:length(binsizes)
            binend = binstart + binsizes(i) - 1;
            firstletter = allletters( binstart );
            if i==length(binsizes)
                lastletter = 'Z';
            else
                lastletter = allletters( binend );
            end
            if firstletter==lastletter
                binlabel = upper(firstletter);
            else
                binlabel = upper([firstletter '-' lastletter]);
            end
          % fprintf( 1, 'Adding menu %s.\n', ['Commands ' binlabel ] );
            binmenu = uimenu( 'Label', binlabel, 'Parent', hmenu );
            % add submenu
            for j=binstart:binend
            	uimenu( 'Label', okcmdnames{j}, ...
                        'Parent', binmenu, ...
                        'UserData', cmddir, ...
                        'Callback', @cmdMenuCallback );
            end
%             if i==1
%                 set( binmenu, 'Separator', 'on' );
%             end
            binstart = binend+1;
        end
    end
    
    uimenu( 'Parent', hmenu, ...
            ... % 'Label', '<HTML><body><i>Commands (topic)</i></bodyd</HTML>', ...
            'Label', 'Commands (topic)', ...
            'Separator', 'on', 'Enable', 'off' );
    for i=1:length(alltags)
        tag = alltags{i};
        topicmenu = uimenu( 'Label', tag, 'Parent', hmenu );
        cmds = tagtocmd.(tagtofield(tag));
        for j=1:length(cmds)
        	uimenu( 'Label', cmds{j}, ...
                    'Parent', topicmenu, ...
                    'UserData', cmddir, ...
                    'Callback', @cmdMenuCallback );
        end
%         if i==1
%             set( topicmenu, 'Separator', 'on' );
%         end
    end

function isbad = haveBadTag( tags )
    for k=1:length(tags)
        for m=1:length(badtags)
            if strcmp( tags{k}, badtags{m} )
                isbad = true;
                return;
            end
        end
    end
    isbad = false;
end
end

function f = tagtofield( t )
    f = regexprep( t, '[^A-Za-z0-9_]', '_' );
end

function cmdMenuCallback( hObject, eventData )
    cmdfile = get( hObject, 'Label' );
    cmddir = get( hObject, 'UserData' );
  % fprintf( 1, 'Callback for %s called.\n', cmdfile );
    ht = get1HelpText( fullfile( cmddir, cmdfile ) );
    if isempty(ht)
        ht = 'COULD NOT LOAD HELP TEXT.\n';
    end
    textdisplayDlg('theText', ht, 'title', cmdfile,'size',[700,600]);
end

function [ht,tags] = get1HelpText( cmdfile )
    fid = fopen( [cmdfile,'.m'], 'r' );
    if fid==-1
        fprintf( 1, 'Could not open %s.\n', cmdfile );
        return;
    end
    [ht,tags] = readHelpText( fid );
    fclose( fid );
end

function [ht,tags] = readHelpText( fid )
    headerlines = {};
    ht = '';
    tags = {};
    
    % Detect the start of the function header.
    while true
        line = fgetl( fid );
        if regexp( line, '^ *function ', 'once' )
            break;
        elseif islayout( line )
            continue;
        elseif iscomment( line )
            continue;
        else
            return;
        end
    end
    % Skip over any continuation lines
    line = fgetl( fid );
    while (~iseof(line)) && (~iscomment( line )) && ~isempty(regexp( line, '\.\.\.', 'once' ))
        line = fgetl( fid );
    end
    % Skip over empty lines
    while (~iseof(line)) && islayout( line )
        line = fgetl( fid );
    end
    
    if iseof(line) || ~iscomment(line)
        return;
    end
    headerlines{end+1} = regexprep( line, '^\s*%', '' );
    headerlines{end+1} = '';
    
    while true
        line = fgetl( fid );
        if iseof(line) || ~iscomment(line)
            break;
        end
        line = regexprep( line, '\s+$', '' );
        headerlines{end+1} = regexprep( line, '^\s*%', '' );
    end
    if isempty(headerlines)
        ht = '';
        return;
    end
    lastline = headerlines{end};
    ht = [ joinstrings( char(10), headerlines ), char(10) ];
    topicprefix = '^ *Topics?: *';
    if regexp( lastline, topicprefix, 'once' )
        lastline = regexprep( lastline, topicprefix, '' );
        lastline = regexprep( lastline, ' *\.? *$', '' );
        tags = splitString( ', *', lastline );
    end
end

function isc = iscomment( line )
    isc = ~isempty(regexp( line, '^ *%', 'once' ));
end

function isl = islayout( line )
    isl = ~isempty(regexp( line, '^\s*$', 'once' ));
end

function e = iseof( l )
    e = (length(l)==1) && (l==-1);
end

