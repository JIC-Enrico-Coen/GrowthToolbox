function result = checkheight( m, field, height, complainer )
    if isfield( m, field ) && (size(m.(field),1) ~= height)
        result = 0;
        complainer( ['validmesh:' field], ...
            'Wrong size of %s: %d, expected %d.', ...
            field, size(m.(field),1), height );
    else
        result = 1;
    end
end
