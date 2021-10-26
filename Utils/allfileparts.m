function p = allfileparts( f )
    p = {};
    while ~isempty(f)
        [f1,basename] = dirparts(f);
        if ~isempty(basename)
            p{end+1} = basename;
        end
        if strcmp(f1,f)
            p{end+1} = f1;
            break;
        end
        f = f1;
    end
    p = { p{end:-1:1} };
end
