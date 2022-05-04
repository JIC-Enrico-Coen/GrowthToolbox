function [suniqueindexes,ia,ic,sindexes] = uniqueRowsCellArray( s )
%[suniqueindexes,ia,ic,sindexes] = uniqueRowsCellArray( s )
%   This finds the unique rows of a two-dimensional cell array. The Matlab
%   function unique() can be applied to a cell array only if all elements
%   are numeric or all elements are strings. This function is slightly more
%   flexible: it requires only that each column of the cell array has that
%   property.

    sindexes = zeros( size(s) );
    for i=1:size(s,2)
        s1 = s(:,i);
        if isnumeric( s1{1} )
            s1 = cell2mat( s1 );
        end
        [~,~,ic] = unique( s1 );
        sindexes(:,i) = ic;
    end
    [suniqueindexes,ia,ic] = unique( sindexes, 'rows', 'stable' );
end
