function [newfaces,newpointweights] = subdividePolyhedronType( faces, tension )
%[newfaces,newpointweights] = subdividePolyhedronType( faces, tension )
%   Calculate data for subdividing a polyhedron composed of triangular
%   faces by the butterfly method.  This assumes the polyhedron has a
%   closed surface.
%   It does not use the actual positions of any of the points, but instead
%   returns the linear combinations from which they can be calculated,
%   together with the new triangles.

    octafaces = [ 1 3 6;
                  3 2 6;
                  2 4 6;
                  4 1 6;
                  3 1 5;
                  2 3 5;
                  4 2 5;
                  1 4 5 ];

    if nargin < 3
        tension = 1/16;
    end

    wts = [ 1/2 1/2 tension*2 tension*2 -tension -tension -tension -tension ];
    
    f1 = [ faces, (1:size(faces,1))' ];
    f1 = reshape( f1( :, [1 2 4 2 3 4 3 1 4] )', 3, [] )';
    flip = f1(:,1) > f1(:,2);
    f1(flip,[1 2]) = f1(flip,[2 1]);
    [edgeends,ia,ic] = unique( f1(:,[1 2]), 'rows' );
    
    
    ec = [ic, f1(:,3) ];
    
    
    edgecells = sort( ec, 1 );
    edgecells = [ edgecells(1:2:end,[1 2]), edgecells(2:2:end,2) ];
    celledges = sort( ec(:,[2 1]), 1 );
    celledges = [ celledges(1:3:end,[1 2]), celledges(2:3:end,2), celledges(3:3:end,2) ];
    

    p1 = edgeends( ei, 1 );
    p2 = edgeends( ei, 2 );
    c1 = edgecells( ei, 1 );
    c2 = edgecells( ei, 2 );
    
    p3 = othervertex( m, c1, p1, p2 );

    e11 = celledges( c1, faces(c1,:)==p2 );
    c11 = othercell( m, c1, e11 );
    if c11 == 0
        p5 = 0;
        corr5 = wts(5) * [ 1 -1 1 0 -1 0 0 0 ];
    else
        p5 = faces( c11, celledges(c11,:)==e11 );
        corr5 = zeros(1,8);
    end

    e12 = celledges( c1, faces(c1,:)==p1 );
    c12 = othercell( m, c1, e12 );
    if c12 == 0
        p6 = 0;
        corr6 = wts(6) * [ -1 1 1 0 0 -1 0 0 ];
    else
        p6 = faces( c12, celledges(c12,:)==e12 );
        corr6 = zeros(1,8);
    end
    
    p4 = othervertex( m, c2, p1, p2 );

    e21 = celledges( c2, faces(c2,:)==p2 );
    c21 = othercell( m, c2, e21 );
    if c21 == 0
        p7 = 0;
        corr7 = wts(7) * [ 1 -1 0 1 0 0 -1 0 ];
    else
        p7 = faces( c21, celledges(c21,:)==e21 );
        corr7 = zeros(1,8);
    end

    e22 = celledges( c2, faces(c2,:)==p1 );
    c22 = othercell( m, c2, e22 );
    if c22==0
        corr8 = wts(8) * [ -1 1 0 1 0 0 0 -1 ];
        p8 = 0;
    else
        corr8 = zeros(1,8);
        p8 = faces( c22, celledges(c22,:)==e22 );
    end
    
    wts = wts + corr5 + corr6 + corr7 + corr8;
    pts = [ p1 p2 p3 p4 p5 p6 p7 p8 ];
    pts = pts( wts ~= 0 );
    wts = wts( wts ~= 0 );
end

function pi3 = othervertex(faces,ci,pi1,pi2)
    for i=1:3
        trypi = faces(ci,i);
        if (trypi ~= pi1) && (trypi ~= pi2)
            pi3 = trypi;
            break;
        end
    end
end
