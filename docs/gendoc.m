function gendoc()
    global docstruct fieldmap defaultdocstruct anoncount
    anoncount = 0;
    fieldmap = struct( 'T', 'type', ...
                       'P', 'parent', ...
                       'U', 'username', ...
                       'D', 'desc' );
    fn = fieldnames(fieldmap);
    defaultdocstruct = struct();
    for i=1:length(fn)
        defaultdocstruct.(fieldmap.(fn{i})) = '';
    end
    defaultdocstruct.confirmed = false;
    defaultdocstruct.printed = false;
    defaultdocstruct.children = [];
    whereami = which('GFtbox');
    homedir = fileparts(fileparts(whereami));
    docsdir = fullfile( homedir, 'docs' );
    docsname = fullfile( docsdir, 'docs.txt' );
    newdocsname = fullfile( docsdir, 'docsNEW.txt' );
    [docstruct,ok] = readdocsfile( docsname );
    if ~ok, return; end
    progname = 'GFtbox';
    try
        fig = openfig( [progname, '.fig'] );
    catch e
        complain( 'Cannot open figure file %s:\n    %s\n', ...
            [progname, '.fig'], e.message );
        return;
    end
    crawlfig( fig );
    rootname = get( fig, 'Tag' );
    close(fig);
    docstruct = setchildren( docstruct );
    ok = writedocsfile( rootname, newdocsname );
end

function ds = setchildren( ds )
    fns = fieldnames( ds );
    for i=1:length(fns)
        fn = fns{i};
        parent = ds.(fn).parent;
        if ~isempty(parent)
            ds.(parent).children{ length(ds.(parent).children) + 1 } = fn;
        end
    end
end

function a = ancestors( ds, f )
    a = {};
    if isfield( ds, f )
        a = ancestors( ds, ds.(f).parent );
        a{length(a)+1} = ds.(f).name;
    end
end

function hds = inserthier( hds, fields, value )
    if isempty(fields)
        hds = value;
    else
        f = fields{1};
        if ~isfield( hds, f )
            hds.(f) = struct();
        end
        hds.(f) = inserthier( hds.(f), {fields{2:end}}, value );
    end
end
        
function hds = makehierarchy( ds )
    fns = fieldnames( ds );
    for i=1:length(fns)
        fn = fns{i};
        a = ancestors( ds, fn );
        hds = inserthier( hds, a, ds.(fn) );
        parent = ds.(fn).parent;
        if isempty(parent)
            hds.(fn) = ds.(fn);
            hds.(fn).children = [];
        else
            
        end
    end
end

function ok = writedocsfile( rootname, docsname )
    ok = false;
    if exist( docsname, 'file' )
        docsbakname = regexprep( docsname, '\.txt$', 'BAK.txt' );
        if strcmp(docsbakname,docsname)
            complain( 'Docs filename does not end with .txt: ''%s''.\n', ...
                docsname );
            return;
        end
        try
            copyfile( docsname, docsbakname );
        catch e
            complain( 'Cannot make backup copy of %s:\n    %s\n', ...
                docsname, e.message );
            return;
        end
    end
    fid = fopen( docsname, 'w' );
    if fid==-1
        complain( 'Cannot open figure file %s.\n', ...
            [progname, '.fig'] );
        return;
    end
    writedocsitems( fid, rootname );
    global docstruct
    fns = fieldnames( docstruct );
    for i=1:length(fns)
        fn = fns{i};
        if ~docstruct.(fn).printed
            writedocsitem( fid, fn );
        end
    end
    fclose(fid);
    ok = true;
end

function writedocsitem( fid, tag )
    global docstruct
    d = docstruct.(tag);
    if ~d.confirmed
        fprintf( 1, 'Doc item %s does not exist in figure.\n', ...
            tag );
    end
    fprintf( fid, '=%s=T%s=P%s=U%s=D%s\n', ...
        tag, d.type, d.parent, d.username, d.desc );
    for j=1:length(d.doc)
        fwrite( fid, d.doc{j} );
        fwrite( fid, char(10) );
    end
    if length(d.doc)==0
        fwrite( fid, char(10) );
    end
    docstruct.(tag).printed = true;
end

function writedocsitems( fid, tag )
    global docstruct
    writedocsitem( fid, tag );
    c = docstruct.(tag).children;
    for i=1:length(c)
        writedocsitems( fid, c{i} );
    end
end

function [d,ok] = readdocsfile( docsname )
    ok = false;
    d = struct();
    fid = fopen( docsname, 'r' );
    if fid==-1
        complain( 'Cannot open figure file %s.\n', ...
            [progname, '.fig'] );
        return;
    end
    name = '';
    nextline = 1;
    while true
        s = fgetl( fid );
        if (length(s)==1) && (s==-1)
            break;
        end
        [newname,props] = parseHeader( s );
        if isempty(newname)
            if ~isempty(name)
                d.(name).doc{nextline} = s;
                nextline = nextline+1;
            end
        else
            name = newname;
            d.(name) = props;
            d.(name).doc = {};
            nextline = 1;
        end
    end
    fclose(fid);
    ok = true;
end

function s = safemember( c, i )
    if i <= length(c)
        s = c{i};
    else
        s = '';
    end
end

function [name,props] = parseHeader( s )
    global defaultdocstruct
    name = '';
    props = defaultdocstruct;
    if isempty(s) || (s(1) ~= '=')
        return;
    end
    global fieldmap
    tokens = splitString( '=', s(2:end) );
    if isempty(tokens)
        return;
    end
    name = tokens{1};
    for i=2:length(tokens)
        t = tokens{i};
        if isempty(t)
            continue;
        end
        c = t(1);
        t = t(2:end);
        if isfield( fieldmap, c )
            props.(fieldmap.(c)) = t;
        end
    end
end

function crawlfig( h )
    global docstruct anoncount
    if ishandle( h )
        t = get( h, 'Tag' );
        if isempty(t)
            fprintf( 1, 'Anonymous handle %f:\n', t );
            get(t);
            anoncount = anoncount+1;
            t = sprintf( 'anon_%03d', anoncount );
        end
        if ~isfield( docstruct, t )
            docstruct.(t) = struct( 'desc', '' );
            docstruct.(t).doc = {};
        end
        username = guiElementUsername( h );
        type = get( h, 'Type' );
        if strcmp( type, 'uicontrol' )
            type = get( h, 'Style' );
        end
        parent = get( h, 'Parent' );
        if ishandle(parent)
            parent = get( parent, 'Tag' );
        else
            parent = '';
        end
        if regexp( username, '^(Show|Hide) ' )
            username = [ 'Show/Hide ', username(6:end) ];
        end
        if ~isempty(t)
            docstruct.(t).type = type;
            docstruct.(t).parent = parent;
            docstruct.(t).username = username;
            docstruct.(t).confirmed = true;
            docstruct.(t).printed = false;
            docstruct.(t).children = {};
        end
        c = get( h, 'Children' );
        for i=1:length(c)
            crawlfig( c(i) );
        end
    end
end

function username = guiElementUsername( h )
    [username,ok] = tryget( h, 'Label' );
    if ~ok
        [username,ok] = tryget( h, 'Title' );
    end
    if ~ok
        [username,ok] = tryget( h, 'String' );
    end
    if ok
        username = uncell( username );
        if ~ischar(username)
            username = '';
        end
    end
end

function s = uncell( s )
    while iscell(s)
        if isempty(s)
            s = '';
        else
            s = s{1};
        end
    end
end