function rectarray = raggedToRectangularArray( raggedarray )
%NOT USED
%rectarray = raggedToRectangularArray( raggedarray )
%   RAGGEDARRAY is a cell array of vectors of various lengths.
%   This transforms it into a rectangular array with one row for each cell,
%   padding out the unused places in any row with NaN.

    % Calculate the maximum length of any row.
    maxlen = 0;
    for i=1:length(raggedarray)
        maxlen = max( length(raggedarray{i}), maxlen );
    end
    
    % Calculate the rectangular array.
    rectarray = NaN( length(raggedarray), maxlen );
    for i=1:length(raggedarray)
        ch = raggedarray{i};
        nv = numel(ch);
        rectarray(i,1:nv) = ch(:)';
    end
end
