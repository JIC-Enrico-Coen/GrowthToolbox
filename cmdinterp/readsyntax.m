function sd = readsyntax( filename )
%syntaxdef = readsyntax( filename )
%   Reads a command syntax definition from the given file.

    global PARAM_TYPES

    PARAM_TYPES.INT = uint8(1);
    PARAM_TYPES.REAL = uint8(2);
    PARAM_TYPES.STRING = uint8(3);
    PARAM_TYPES.FLAG = uint8(4);
    PARAM_TYPES.INTARRAY = uint8(5);
    PARAM_TYPES.REALARRAY = uint8(6);
    
    sd = struct();

    ts = opentokenlinestream( filename );
    if isempty(ts)
        % Error: cannot create token stream.
        return;
    end
    numcmds = 0;
    while 1
        [ts,toks] = readtokenline( ts );
        if isempty(toks)
            return;
        end
        if length(toks) < 2
            % Error.
            fprintf( 1, 'Fewer than two tokens found on line %d.\n', ts.curline );
            continue;
        end
        cmdname = toks{1};
        if ~isDotName( cmdname )
            %Error
            continue;
        end
        matlabname = toks{2};
        if ~isMatlabName( matlabname )
            % Error.
            continue;
        end
        % Remaining tokens must all be valid Matlab names.
        oknames = 1;
        for i=3:length(toks)
            if ~isMatlabName( toks{i} )
                % Error.
                oknames = 0;
                break;
            end
        end
        if ~oknames
            % Error.
            continue;
        end
        i = 3;
        curarg = 0;
        params = {};
        numparams = 0;
        syntaxdef = [];
        while i <= length(toks)
            if isfield( PARAM_TYPES, toks{i} )
                curarg = curarg+1;
                if numparams==0
                    numparams = 1;
                    params{numparams}.name = '';
                end
                params{numparams}.args(curarg) = PARAM_TYPES.(toks{i});
            else
                % Parameter name
                numparams = numparams+1;
                params{numparams}.name = toks{i};
                params{numparams}.args = [];
                curarg = 0;
            end
            i = i+1;
        end
        numcmds = numcmds+1;
        syntaxdef(numcmds).name = cmdname;
        syntaxdef(numcmds).matlabname = matlabname;
        syntaxdef(numcmds).params = params;
        syntaxdef(numcmds).paramstruct = makeStruct( params );
        syntaxdef(numcmds).paramorder = makeOrder( params );
        eval( [ 'sd.' cmdname ' = syntaxdef(numcmds);' ] );
      %  syntaxdef(numcmds) = struct( 'name', cmdname, ...
      %                               'matlabname', matlabname, ...
      %                               'params', [params] );
        cmdcpts = regexprep( cmdname, '\.', ' ' );
        sd.matlabnamelookup.(matlabname) = cmdcpts;
    end
end

function s = makeStruct( params )
    if isempty(params)
        s = struct();
    else
        for i=1:length(params)
            if isempty( params{i}.name )
                s.ARGS = params{i}.args;
            else
                s.(params{i}.name) = params{i}.args;
            end
        end
    end
end

function s = makeOrder( params )
    if isempty(params)
        s = struct();
    else
        for i=1:length(params)
            if isempty( params{i}.name )
                s.ARGS = i;
            else
                s.(params{i}.name) = i;
            end
        end
    end
end
