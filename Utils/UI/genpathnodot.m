function s = genpathnodot( d )
%s = genpathnodot( d )
%   Like genpath, except that the argument is required, and directories
%   whose name begins with a dot are excluded.

    if ~exist( d, 'dir' )
        s = '';
        return;
    end
    s = d;
    x = dir(d);
    n = {x.name};
    n = n([x.isdir]);
    good = false( 1, length(n) );
    for i=1:length(n)
        n1 = n{i};
        good(i) = (~isempty(n1)) ...
                  && (n1(1) ~= '.') ...
                  && (n1(1) ~= '@') ...
                  && (~strcmp( n1, 'private' )) ...
                  && (~strcmp( n1, 'CVS' ));
    end
    n = n(good);
    for i=1:length(n)
        s = [ s, ';', genpathnodot( fullfile( d, n{i} ) ) ];
    end
end
