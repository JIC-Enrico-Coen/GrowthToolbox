function structeq( A, B, varargin )
%structeq( A, B )
%   Compare two structs for equality and print a report of the difference.
%   This is a quick and dirty test intended for structs of which every
%   member is a numerical array.

    if isempty(varargin)
        f = fields(A);
    else
        f = varargin;
    end
    ok = 1;
    for i=1:length(f)
        diff = reshape(A.(f{i}),1,[]) - reshape(B.(f{i}),1,[]);
        rat = diff ./ reshape(B.(f{i}),1,[]);
        dm = max( abs( diff ) );
        rm = max( abs( rat ) );
        if (dm > 0) || (rm ~= 0)
            fprintf( 1, 'Structs differ in field %s by diff %g, ratio %g.\n', ...
                f{i}, dm, rm );
            ok = 0;
        end
    end
    if ok
        fprintf( 1, 'Structs are identical.\n' );
    end
end
