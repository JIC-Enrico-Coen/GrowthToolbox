function [ts,v] = tscmds( ts, syntaxdef, v, do )
%v = tscmds( ts, syntaxdef, v )
%   Apply commands from the given token stream, with meanings defined by syntaxdef,
%   to the structure v.

% Need to exclude keywords from input file.

    if isfield( syntaxdef, 'paramstruct' )
        if isfield( syntaxdef.paramstruct, 'ARGS' )
            % Read unnamed arguments.
            [ts,v] = readUnnamedArgs( ts, syntaxdef, v, do );
        else
            % Read named arguments.
            [ts,v] = readNamedArgs( ts, syntaxdef, v, do );
        end
        % If valid, execute command.
    else
        while 1
            [ts,t] = readtoken( ts );
            if isempty(t), return; end
            if isfield( syntaxdef, t )
                [ts,v] = tscmds( ts, syntaxdef.(t), v, do );
            else
                % Unrecognised token terminates command, return to parent.
                ts = putback( ts, t );
                return;
            end
        end
    end
end

function [ts,args] = readArgs( ts, argtypes )
    global PARAM_TYPES
    numargs = length( argtypes );
    args = cell(1,numargs);
    for i = 1:numargs
        argtype = argtypes(i);
        if (argtype==PARAM_TYPES.INTARRAY) || (argtype==PARAM_TYPES.REALARRAY)
            [ts,argarray] = readNumbers( ts );
            if argtype==PARAM_TYPES.INTARRAY
                argarray = int32(argarray);
            end
            args{i} = argarray;
        else
            [ts,arg] = readtoken( ts );
            if isempty(arg)
                % Note: missing args.
                args = [args{1:i-1}];
                break;
            end
            [argval,ok] = istype( arg, argtype );
            if ok
                args{i} = argval;
            else
                % Note: missing args.
                args = [args{1:i-1}];
                ts = putback( ts, arg );
                break;
            end
        end
    end
end

function [ts,v] = readUnnamedArgs( ts, syntaxdef, v, do )
    [ts,args] = readArgs( ts, syntaxdef.paramstruct.ARGS );
    v = docmd( v, syntaxdef, { args }, do );
end

function f = isflag( args )
    global PARAM_TYPES
    f = (length(args)==1) && (args(1)==PARAM_TYPES.FLAG);
end

function [ts,v] = readNamedArgs( ts, syntaxdef, v, do )
    args = struct();
    while 1
        [ts,t] = readtoken( ts );
        if isempty(t), break; end
        negflag = t(1)=='-';
        if negflag
            t = t(2:end);
        end
        if isempty(t), break; end
        if ~isfield( syntaxdef.paramstruct, t )
            if negflag
                % Syntax error: negative flag not recognised.
                fprintf( 1, 'Command syntax error: unknown negative flag "-%s" ignored.\n', ...
                    t );
            else
                ts = putback( ts, t );
            end
            break;
        end
        if isflag( syntaxdef.paramstruct.(t) )
            args.(t) = ~negflag;
            continue;
        elseif negflag
            % Syntax error: negative flag not recognised.
            fprintf( 1, 'Command syntax error: unknown negative flag "-%s" ignored.\n', ...
                t );
            continue;
        else
            [ts,argvec] = readArgs( ts, syntaxdef.paramstruct.(t) );
        end
        args.(t) = argvec;
    end
    % Execute command.

    v = docmd( v, syntaxdef, args, do );
end

function al = arglist( argstruct )
    fields = fieldnames( argstruct );
    nf = length(fields);
    al(1:2:(nf+nf-1)) = [ fields{:} ];
    for i=1:length(fields)
        al(i+i) = argstruct.(fields{i});
    end
end

function v = docmd( v, syntaxdef, args, do )
    if do
        al = arglist( args );
        v = feval( syntaxdef.matlabname, v, al{:} );
    else
        cmd = [ 'm = ', syntaxdef.matlabname, ' ', syntaxdef.name, '( m' ];
        fields = fieldnames( args );
        for i=1:length(fields)
            cmd = [ cmd ', ' char(39) fields{i} char(39) ', ' argToMatlabString( args.(fields{i}) ) ];
        end
        cmd = [ cmd ' );' char(10) ];
        v = [ v cmd ];
    end
end

function [argval,ok] = istype( arg, argtype )
    global PARAM_TYPES

    switch argtype
        case PARAM_TYPES.INT
            argval = textscan( arg, '%d' );
            argval = argval{1};
            ok = ~isempty(argval);
            if ok, argval = int32( argval ); end
        case PARAM_TYPES.REAL
            argval = textscan( arg, '%f' );
            argval = argval{1};
            ok = ~isempty(argval);
        case PARAM_TYPES.STRING
            argval = char( arg );
            ok = 1;
        case PARAM_TYPES.FLAG
            argval = char( arg );
            ok = 1;
        otherwise
            argval = [];
            ok = 0;
    end
end

