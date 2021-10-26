function a = extendSplit( a, ends, mode )
%a = extendSplit( a, ends1, ends2 )
%   A is an N*1 array defining a quantity per vertex.
%   ENDS is an N*2 array of pairs of vertex indexes, defining a set of edges.
%   Assuming that a new vertex is to be added to the midpoint of every
%   edge, calculate the value that A should have at each of those vertexes.
%   The rule for calculating the new values is given by the MODE parameter:
%
%   'ave': average
%   'min': minimum
%   'max': maximum
%   anything else: zero.
    
    if ~isempty(a)
        a = [ a; splitVals( a, ends, mode ) ];
    end
end
