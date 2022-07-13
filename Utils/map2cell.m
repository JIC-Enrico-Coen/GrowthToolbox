function b = map2cell( a )
%b = map2cell( a )
%   A is an N*K array. Its first column is expected to consist of indexes
%   into some other array. For each such index I, B{I} will be the array
%   consisting of all the rows of A that begin with that index, with the
%   index omitted.

    a1 = sortrows( a );
    repdata = countreps( a1(:,1) );
    starts = repdata(:,3);
    ends = starts + repdata(:,2) - 1;
    numitems = size(repdata,1);
    b = cell( numitems, 1 );
    for i=1:numitems
        b{repdata(i,1)} = a1( starts(i):ends(i), 2:end );
    end
end