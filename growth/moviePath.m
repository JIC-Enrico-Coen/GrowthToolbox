function p = moviePath( m )
%p = moviePath( m )
%   Return the full path name of the movies directory of m.  If m is empty
%   or does not belong to a project, p is empty.  The movies directory does
%   does not have to exist, and if it does not it will not be created.

    p = projectPath( m );
    if ~isempty(p)
        p = fullfile( p, 'movies' );
    end
end
