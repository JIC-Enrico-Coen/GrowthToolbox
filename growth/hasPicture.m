function hp = hasPicture( m )
    hp = isfield( m, 'pictures' ) && (~isempty(m.pictures)) && ishandle( m.pictures(1) );
end
