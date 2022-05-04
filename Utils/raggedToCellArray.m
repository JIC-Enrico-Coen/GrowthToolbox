function ca = raggedToCellArray( ra, nullvalue )
%ca = raggedToCellArray( ra, nullvalue )
%   Given an N*K array in which occurrences of nullvalue represent
%   missing values, produce an N*1 cell array, in which the Nth cell
%   contains the Nth row excluding the null values.
%
%   See also: cellToRaggedArray

    nullIsNan = isnan(nullvalue);
    ca = cell( size(ra,1), 1 );
    for i=1:size(ra,1)
        xx = ra(i,:);
        if nullIsNan
            ca{i} = xx(~isnan(xx));
        else
            ca{i} = xx(xx ~= nullvalue);
        end
    end
end
