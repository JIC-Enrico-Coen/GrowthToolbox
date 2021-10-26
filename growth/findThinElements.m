function [thinedges,thinness] = findThinElements( m )
%thinedges = findThinElements( m )
%   Find every edge of the finite element mesh which is longer than the
%   perpendicular altitude by a ratio of more than
%   m.globalProps.splitthinness.
%
%   UNDER DEVELOPMENT, NOT CURRENTLY WORKING.

    % Get the length of every edge.
    es = eligibleEdges( m );  % Bitmap of edges.
    candidateedges = find(es);
    % es = rand(size(m.edgeends,1),1) < 0.25;
    ee = m.edgeends( es, : );  % EE * 2 -> V
    ec = m.edgecells( es, : );% EE * 2 -> C
    edgevecs = m.nodes( ee( :, 2 ), : ) ...
               - m.nodes( ee( :, 1 ), : );  % EE * 3 -> double
    edgelensqs = sum( edgevecs.*edgevecs, 2 );  % EE -> double
    area1 = m.cellareas( ec(:,1) );
    havecell2 = ec(:,2) > 0;
    area2 = m.cellareas( ec(havecell2,2) );
    thinness1 = edgelensqs./area1;
    thinness2 = edgelensqs(havecell2)./area2;
    
    
    alledgelensqs = zeros( size(m.edgeends,1), 1 );
    alledgelensqs(es) = edgelensqs;
    celledgelensqs = alledgelensqs(m.celledges);
    celledgethinness = celledgelensqs ./ repmat( m.cellareas, 1, 3 );
    celledgethinmap = celledgethinness > maxthinness;
    celledgethickmap = (celledgethinness > 0) && (celledgethinness < minthinness);
    edgethinmap
    
    % An edge should be split due to thinness if:
    % 1. It is thin in one of the cells it belongs to, and the other two
    % edges are thick, and
    % 2. If it has a cell on the other side, the other two edges of that
    % cell are thick.  (It does not matter whether this edge is thin or
    % thick in that cell.)
    
    thinthickthick = (sum( celledgethickmap, 2 )==1) && all( celledgethinmap | celledgethickmap, 2 );
    thickthickthick = all( celledgethickmap, 2 );
    
    for i=find(es(:))'
        c1 = m.edgecells(i,1);
        c2 = m.edgecells(i,2);
        if thinthickthick(c1)
            ei1i = find( celledgethickmap(c1,:), 1 );
            ei1 = m.celledges(c1,ei1i);
            if ei1==i
                if c2 ~= 0
                    ei2i = find( m.celledges(c2,:)==ei1, 1 );
                    ei2 = m.celledges(c2,ei2i);
                    if ei2i==ei1
                        % check the other two edges are thick
                        xx = celledgethickmap(c2,:);
                        xx(ei2i) = true;
                        if all(xx)
                            % Eligible!
                        end
                    end
                end
            end
        end
                % Check that c2 is 0, thinthickthick for ei, or
                % *thickthick
    end
    
    
    
    
    maxthinness = 2*m.globalProps.splitthinness;
    THINNESS_SEPARATION = 0.8;
    minthinness = maxthinness * THINNESS_SEPARATION;
    
    thinedgemap1 = es;
    thinedgemap1(candidateedges(thinness1 > maxthinness)) = true;
    thickedgemap1 = es;
    thickedgemap1(candidateedges(thinness1 < minthinness)) = true;
    thinedgemap2 = es;
    thinedgemap2(candidateedges(thinness1 > maxthinness)) = true;

    isthin2 = false(size(thinness1));
    isthin2(havecell2) = thinness2 > maxthinness;
    thinedges = (thinness1 > maxthinness) | isthin2;
    
    
    
    
    
    
    
    if nargout >= 2
        thinness = thinness1;
        thinness(havecell2) = max( thinness(havecell2), thinness2 );
    end
    thinedgemap = es;
    thinedgemap(es) = thinedges;
    thinedgesincellmap = thinedgemap( m.celledges );
    nonuniquethinedgeincellmap = sum(thinedgesincellmap,2) ~= 1;
    thinedgemap(m.celledges(nonuniquethinedgeincellmap,:)) = false;
    thinedges = find(thinedgemap); % candidateedges(thinedges);
    if ~isempty(thinedges)
        xxxx = 1;
    end
end
