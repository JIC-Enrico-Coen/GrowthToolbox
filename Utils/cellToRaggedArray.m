function ra = cellToRaggedArray( ca, nullvalue, pad )
%ra = cellToRaggedArray( ca, nullvalue, pad )
%   CA is an N*1 cell array of vectors of numbers of various lengths. This
%   converts it to a rectangular array in which short rows are padded out
%   with NULLVALUE, by default NaN.
%
%   The elements of CA can also be rectangular arrays. These will be
%   concatenated vertically, padded with NULLVALUE as required.
%
%   If PAD is true (the default is false) then every row of the resulting
%   array will end with at least one NULLVALUE.
%
%   See also: raggedToCellArray

    if ~iscell(ca)
        ra = ca;
        return;
    end
    
    if isempty(ca)
        ra = [];
        return;
    end
    
    if (nargin < 2) || isempty( nullvalue )
        if isfloat(ca{1})
            nullvalue = NaN;
        elseif isnumeric(ca{1})
            nullvalue = 0;
        elseif islogical(ca{1})
            nullvalue = false;
        else
            nullvalue = 0;
        end
    end
    if nargin < 3
        pad = false;
    end
    n = numel(ca);
    maxlen = 0;
    numrows = 0;
    for i=1:n
        numrows = numrows + size(ca{i},1);
        maxlen = max( maxlen, size(ca{i},2) );
    end
    if pad
        maxlen = maxlen+1;
    end
    ra = nullvalue + zeros( numrows, maxlen );
    nrr = 0;
    for i=1:n
        x = ca{i};
        nr = size(x,1);
        ra((nrr+1):(nrr+nr),1:size(x,2)) = x;
        nrr = nrr+nr;
    end
end
