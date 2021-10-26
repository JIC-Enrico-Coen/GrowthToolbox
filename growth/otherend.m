function vi1 = otherend( m, vi, ei )
%vi1 = otherend( m, vi, ei )
%   If vi is the vertex at one end of edge ei, return the vertex on the other
%   end.
%   ei can be a vector, and vi1 will be a vector of the same length.

    firsts = vi==m.edgeends(ei,1);
    vi1 = zeros(1,length(ei));
    for i=1:length(ei)
        vi1(i) = m.edgeends(ei(i),1+firsts(i));
    end
end
