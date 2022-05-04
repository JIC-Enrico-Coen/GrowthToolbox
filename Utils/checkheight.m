function result = checkheight( m, field, height, severity )
    if nargin < 4
        severity = 0;
    end
    if isfield( m, field ) && (size(m.(field),1) ~= height)
        result = 0;
        complain2( severity, ...
            'Wrong size of %s: %d, expected %d.', ...
            field, size(m.(field),1), height );
    else
        result = 1;
    end
end
