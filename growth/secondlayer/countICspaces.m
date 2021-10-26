function [numICspaces,icVxs,cycleends] = countICspaces( m )
%[numICspaces,icVxs,cycleends] = countICspaces( m )
%   Find all the intercellular spaces.  These are not represented
%   explicitly in the m.secondlayer structure.  Instead, the edges
%   adjoining them are marked by having m.secondlayer.edges(...,4) equal to
%   -1.  (A positive number would signify a cell, and 0 would signify that
%   the edge is on the border of the cellular tissue.)
%
%   numICspaces is how many spaces there are.
%
%   icVxs is a list of the second layer vertexes adjoining all of the IC
%   spaces.  The list of vertexes for each IC space is terminated with a
%   zero.  A typical list looks like:
%
%       [ 989 15 16 0 1077 28 1076 0 42 991 990 1037 41 57 0 ... ]
%
%   cycleends is a list of the indexes of all the zeros in icVxs.  In the
%   example this would be [ 4 8 15 ... ].

    % Find all edges that border an IC space.
    icEdges = m.secondlayer.edges(:,4)==-1;
    
    % Get the pairs of vertexes they join.
    icEdgeEnds = m.secondlayer.edges(icEdges,[1 2]);

    % Group them into the cycles that enclose each space.
    icVxs = findCycles( icEdgeEnds );

    % icVxs lists the vertexes of all the cycles, each cycle
    % terminated by a zero.  Find where each cycle begins and ends.
    cycleends = find(icVxs==0);
    numICspaces = length(cycleends);
end
