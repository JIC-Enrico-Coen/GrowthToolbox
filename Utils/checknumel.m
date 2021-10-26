function result = checknumel( m, field, num, complainer )
    if isfield( m, field ) && (numel(m.(field)) ~= num)
        result = 0;
        complainer( ['validmesh:' field], ...
            'Wrong size of %s: %d, expected %d.', ...
            field, numel(m.(field)), num );
    else
        result = 1;
    end
end


