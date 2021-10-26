function e = findMTSegmentElement( mt, seg )
%e = findMTSegmentElement( mt, seg )
%   Given a microtubule MT and an index of one of its segments, find the
%   finite element that that segment lies in.

    % The reason we have split off this into such an apparently trivial
    % procedure is that we are not quite sure that this always gives the
    % right answer. It certainly gives the right answer whenever
    % mt.segcellindex( seg )==mt.segcellindex( seg+1 ), and also when the
    % point indexed by seg+1 is in the interior of an element. But points
    % on the edge of an element can be referred to either of the elements
    % sharing that edge, and points at a vertex can be references to any of
    % the elements sharing that vertex. At present, I believe that for
    % every segment, its final point is always referenced to the element
    % containing that segment, but I am not entirely sure that this
    % property always holds.
    
    e = mt.segcellindex( seg );
end
