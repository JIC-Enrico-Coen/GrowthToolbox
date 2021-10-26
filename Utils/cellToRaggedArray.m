function ra = cellToRaggedArray( ca, nullvalue, pad )
    if nargin < 3
        pad = false;
    end
    n = length(ca);
    maxlen = 0;
    for i=1:n
        maxlen = max( maxlen, length(ca{i}) );
    end
    if pad
        maxlen = maxlen+1;
    end
    ra = nullvalue + zeros( n, maxlen );
    for i=1:n
        x = ca{i};
        ra(i,1:length(x)) = x(:)';
    end
end
