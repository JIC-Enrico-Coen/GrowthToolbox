function es = eligibleEdges( m )
%es = eligibleEdges( m )
%   Return a bitmap of all edges, both ends of which have a corresponding
%   value of splitting morphogen of at least 0.5.  If there is no splitting
%   morphogen, all edges are returned.

    if isempty( m.globalProps.splitmorphogen )
        es = true( size(m.edgeends,1), 1 );
    else
        splitindex = m.mgenNameToIndex.(m.globalProps.splitmorphogen);
        eligibleNodes = m.morphogens(:,splitindex) >= 0.5;
        es = eligibleNodes(m.edgeends(:,1)) & eligibleNodes(m.edgeends(:,2));
    end
end
