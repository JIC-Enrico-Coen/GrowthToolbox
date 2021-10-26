function ca = array2cellarray( a )
%ca = array2cellarray( a )
%   a is an N*2 array which is assumed to be sorted by its first column.
%   The result is a cell array of arrays such that ca{i} is an array of all
%   values of a(:,2) for which the corresponding element of a(:,1)==i.

    if isempty(a)
        ca = {};
        return;
    end

    alen = size(a,1);
    numcells = a(alen,1);
    ca = cell( numcells, 1 );
    start = 1;
    astart = a(start,1);
    for i=2:alen
        if a(i,1) ~= astart
            ca{astart} = a(start:(i-1),2);
            start = i;
            astart = a(start,1);
        end
    end
    ca{astart} = a(start:alen,2);
end
