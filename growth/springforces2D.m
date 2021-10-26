function [nodeforces,stretches] = springforces2D( nodes, edgeends, restlengths, springconst )
%[nodeforces,stretches] = springforces2D( nodes, edgeends, restlengths,
%springconst )
%   NODES is the set of 2D positions of a set of nodes.
%   EDGEENDS is a list of pairs of nodes.
%   RESTLENGTHS is a vector of floats one for each edge, defining the rest
%   length of that edge.
%   SPRINGCONST is a single number, the spring constant of all the springs.
%   NODEFORCES is the set of resulting forces on the nodes.
%   STRETCHES is a vector of floats, one for each edge, which is the amount
%   by which each edge is stretched from its rest length.

    numnodes = size(nodes,1);
    numedges = size(edgeends,1);
    nodeforces = zeros( numnodes, 2 );
    
    edgevecs = nodes( edgeends(:,2), : ) - nodes( edgeends(:,1), : );
    edgelensq = sum( edgevecs.^2, 2 );
    edgelens = sqrt( edgelensq );
    stretches = edgelens - restlengths;
    edgeforcesize = stretches * springconst;
    r = edgeforcesize./edgelens;
    for ei=1:numedges
        n1 = edgeends(ei,1);
        n2 = edgeends(ei,2);
        f = r(ei) * edgevecs(ei,:);
        nodeforces(n1,:) = nodeforces(n1,:) + f;
        nodeforces(n2,:) = nodeforces(n2,:) - f;
    end
end

