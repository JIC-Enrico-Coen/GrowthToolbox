function b = splitVals( a, ends, mode )
%b = splitVals( a, ends1, ends2 )
%   A is an N*1 array defining a quantity per vertex.
%   ENDS is an N*2 array of pairs of vertex indexes, defining a set of edges.
%   Assuming that a new vertex is to be added to the midpoint of every
%   edge, calculate the value for each of those vertexes.
%
%   The rule for calculating the new values is given by the MODE parameter:
%
%       'min': minimum
%       'max': maximum
%       'zer': zero
%       anything else: average.

    switch mode
        case 'min'
            b = min( a(ends(:,1),:), a(ends(:,2),:) );
        case 'max'
            b = max( a(ends(:,1),:), a(ends(:,2),:) );
        case 'zer'
            b = zeros( length(ends1), size(a,2) );
        otherwise
            b = (a(ends(:,1),:) + a(ends(:,2),:))/2;
    end
end
