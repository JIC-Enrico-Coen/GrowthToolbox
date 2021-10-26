function [s,relpaths] = removeGraphicsHandles( s )
%[s,relpaths] = removeGraphicsHandles( s )
%   Remove all of the graphics handles from s.
%   Return in RELPATHS a cell array of all of the paths from the root of s
%   to each structure handle

    [s,relpaths] = removeGraphicsHandles1( s, '', 0 );
end

function [s,relpaths] = removeGraphicsHandles1( s, relpath, depth )
%[s,relpaths] = removeGraphicsHandles( s )

    relpaths = {};
    if isempty(s) || isnumeric(s) || islogical(s) || ischar(s) || isstring(s)
        % Nothing.
    elseif isa(s,'matlab.graphics.Graphics')
%         s(:) = matlab.graphics.GraphicsPlaceholder();
        s = matlab.graphics.Graphics.empty;
        relpaths = { relpath };
    elseif iscell(s)
        for si=1:numel(s)
            [s{si},newrelpaths] = removeGraphicsHandles1( s{si}, [relpath sprintf( '{%d}', si )], depth+1 );
            relpaths = [ relpaths, newrelpaths ];
        end
    elseif numel(s) > 1
        for si=1:length(s)
            [s(si),newrelpaths] = removeGraphicsHandles1( s(si), [relpath sprintf( '(%d)', si )], depth+1 );
            relpaths = [ relpaths, newrelpaths ]; %#ok<*AGROW>
        end
    elseif isstruct(s) || ishandle(s)
        fns = fieldnames(s);
        for i=1:length(fns)
            fn = fns{i};
            if length(s)==1
                relpath1 = [relpath '.' fn];
            else
                relpath1 = [relpath sprintf( '(%d).', si ) fn];
            end
            [s.(fn),newrelpaths] = removeGraphicsHandles1( s.(fn), relpath1, depth+1 );
            relpaths = [ relpaths, newrelpaths ]; %#ok<*AGROW>
        end
    else
        % Nothing.
    end
end
