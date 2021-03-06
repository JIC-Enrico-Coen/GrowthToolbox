function result = checknumel( m, field, num, severity )
%result = checknumel( m, field, num, severity )
%   Check that M.(FIELD) has NUM elements.

    if nargin < 4
        severity = 0;
    end
    if isfield( m, field ) && (numel(m.(field)) ~= num)
        result = 0;
        complain2( severity, ...
            'Wrong size of %s: %d, expected %d.', ...
            field, numel(m.(field)), num );
    else
        result = 1;
    end
end


