function s = argToMatlabString( arg )
    if iscell(arg)
        if isempty(arg)
            s = '{}';
        elseif numel(arg)==1
            s = argToMatlabString( arg{1} );
        else
            s = [ '{ ' argToMatlabString( arg{1} ) ];
            for j=2:length(arg)
                s = [ s ', ' argToMatlabString( arg{j} ) ];
                if mod(j,10)==0
                    s = [ s ' ...' char(10) '        ' ];
                end
            end
            s = [ s ' }' ];
        end
    elseif ischar( arg )
        s = [ char(39) arg char(39) ];
    elseif isempty(arg)
        s = '[]';
    elseif numel(arg) > 1
        s = [ '[ ' argToMatlabString( arg(1) ) ];
        for j=2:length(arg)
            s = [ s ', ' argToMatlabString( arg(j) ) ];
            if mod(j,10)==0
                s = [ s ' ...' char(10) '        ' ];
            end
        end
        s = [ s ' ]' ];
    elseif isinteger(arg) || islogical(arg)
        s = sprintf( '%d', arg );
    elseif isfloat(arg)
        s = sprintf( '%g', arg );
    elseif isstruct(arg)
        s = 'struct( ';
        fn = fieldnames(arg);
        for i=1:length(fn)
            if i>1
                s = [ s ', ' ];
            end
            s = [ s char(39) fn{i} char(39) ', ' argToMatlabString( arg.(fn{i}) ) ];
        end
        s = [ s ' )' ];
    else
        s = [ char(34) arg char(34) ];
    end
end

