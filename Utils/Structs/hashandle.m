function has = hashandle( h, hname )
    has = isfield( h, hname ) && ~isempty( h.(hname) ) && all( ishandle( h.(hname) ) );
end
