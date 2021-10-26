function t = decoratetree( t, decor )
%t = decoratetree( t, decor )
%   Take a tree whose leaves are integers, and make an isomorphic tree
%   whose leaves are the corresponding members of d.

    if isnumeric(t)
        t = decor(t);
    else
        for i=1:length(t)
            t{i} = decoratetree( t{i}, decor );
        end
    end
end
