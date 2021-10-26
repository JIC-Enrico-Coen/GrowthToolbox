function showHandleInfo( h, level, name, seen )
    if isempty(h)
        return;
    end
    if nargin < 2
        level = 0;
    end
    if nargin < 3
        name = '-';
    end
    if nargin < 4
        seen = [];
    end
    
    h = h(ishandle(h));
    if isempty(h)
        return;
    end
    if isnumeric(h)
        if (length(h) > 1) || (h ~= 0) || (nargin > 1)
            return;
        end
    end
    
    if length(h)==1
        tag = tryget(h,'Tag');
        if isempty(tag), tag = '(no tag)'; end
        type = tryget(h,'Type');
        if isempty(tag), tag = '(no type)'; end
        hseen = any(h==seen);
        fprintf( 1, '%*s %s    %s    %s%s\n', level, ':', name, type, tag, boolchar( hseen, '    (seen)', '' ) );
        if ~hseen
            f = get(h);
            fn = fieldnames(f);
            for i=1:length(fn)
                if ~strcmp( fn{i}, 'Parent' )
                    showHandleInfo( f.(fn{i}), level+2, fn{i}, [seen h] );
                end
            end
        end
    else
        for i=1:numel(h)
            showHandleInfo( h(i), level+1, name, seen );
        end
    end
end
