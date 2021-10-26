function s = argToScriptString( arg )
    if iscell(arg)
        if isempty(arg)
            s = '';
        else
            s = argToScriptString( arg{1} );
            for j=2:length(arg)
                s = [ s ', ' argToScriptString( arg{j} ) ];
            end
        end
    elseif ischar( arg )
        s = [ '''' arg '''' ];
    elseif isempty(arg)
        s = '';
    elseif numel(arg) > 1
        c = [];
        if size(arg,1)==1
            c = ',';
        elseif size(arg,2)==1
            c = ';';
        end
        if isempty(c)
            s = argToScriptString( arg(1,:) );
            for i=2:size(arg,1)
                s = [ s, '; ', argToScriptString(arg(i,:)) ];
            end
        else
            s = argToScriptString( arg(1) );
            for j=2:numel(arg)
                s = [ s c ' ' argToScriptString( arg(j) ) ];
            end
        end
        s = [ '[', s, ']' ];
    elseif isinteger(arg) || islogical(arg)
        s = sprintf( '%d', arg );
    elseif isfloat(arg)
        s = sprintf( '%g', arg );
    elseif isstruct(arg)
        s = '';
        if isfield( arg, 'ARGS' )
            s = [ s argToScriptString( arg.(ARGS) ) ];
        end
        fn = fieldnames(arg);
        for i=1:length(fn)
            if ~strcmp( fn{i}, 'ARGS' )
                if i>1
                    s = [ s ' ' ];
                end
                s = [ s fn{i} ' ' argToScriptString( arg.(fn{i}) ) ];
            end
        end
    else
        s = [ '"' arg '"' ];
    end
end

