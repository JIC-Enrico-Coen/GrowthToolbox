function s1 = getLayoutStructItem( s, tag )
    if isfield( s.attribs, 'tag' ) && strcmp( s.attribs.tag, tag )
        s1 = s;
    else
        c = s.children;
        for i=1:length(c)
            s1 = getLayoutStructItem( c{i}, tag );
            if ~isempty(s1)
                return;
            end
        end
        s1 = [];
    end
end
