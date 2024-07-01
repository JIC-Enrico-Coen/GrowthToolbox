function tagStruct = collectTagsRSSS( s )
    if isempty(s)
        return;
    end
    tagStruct = collectTagsRSSS1( struct(), s );
end

function tagStruct = collectTagsRSSS1( tagStruct, s )
    if isempty(s)
        return;
    end
    if isfield( s.attribs, 'tag' ) && ~isempty( s.attribs.tag ) && isfield( s, 'handle' )
        tagStruct.(s.attribs.tag) = s.handle;
    end
    
    for ci = 1:length(s.children)
        tagStruct = collectTagsRSSS1( tagStruct, s.children{ci} );
    end
end

