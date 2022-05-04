function [pbc,qbc,p,q,d] = cutLinesShortest( p12, q12, r, normal )
%[pbc,qbc,p,q] = cutLinesShortest( p12, q12, r, normal )
%   P12 and Q12 are 2x3 arrays defining two line segments.
%   R is a point.
%   P12 and Q12 are presumed to lie in or close to a plane, to which NORMAL
%   is a 1x3 normal vector.
%
%   Find the shortest line passing through the point R and intersecting
%   both line segments, such that R lies between the intersection points.
%   The intersection points will be returned as barycentric coordinates PBC
%   and QBC relative to the two line segments.
%
%   If there is no line through R intersecting both segments, the results
%   are empty.

    % Rotate the whole system to align NORMAL with the Z axis, then ignore
    % the Z coordinate.
    
    v = findPerpVector( normal, p12(2,:)-p12(1,:) );
    w = cross(normal,v);
    rotmat = eye(3); % [v; w; normal];
    p12a = p12*rotmat;
    q12a = q12*rotmat;
    ra = r*rotmat;
    p12a(:,3) = [];
    q12a(:,3) = [];
    ra(:,3) = [];
    
    % Find the two vectors in the plane that make equal angles with p12a
    % and q12a. The shortest cutting line must be in one of these
    % directions.
    
    pva = p12a(2,:) - p12a(1,:);
    qva = q12a(2,:) - q12a(1,:);
    pvau = pva/norm(pva);
    qvau = qva/norm(qva);
    d1 = pvau+qvau;
    d1 = d1/norm(d1);
    d2 = pvau-qvau;
    d2 = d2/norm(d2);
    
    % Choose the one whose direction is closer to that of ra.
    if abs(dot(d1,ra)) > abs(dot(d2,ra))
        d = d1;
    else
        d = d2;
    end
    
    % Find the intersection of the line through r with direction d and each
    % of p12 and q12.
    
    [pbc,qbc,p,q] = testLine( p12a, q12a, ra, d1 );
    p = p';
    q = q';
    between = dot(ra-p,ra-q,2) < 0;
    
    if between
        d = d1;
    else
        [pbc,qbc,p,q] = testLine( p12a, q12a, ra, d2 );
        p = p';
        q = q';
        between = dot(ra-p,ra-q,2) < 0;
        if between
            d = d2;
        else
            xxxx = 1;
        end
    end
    
    [~,pbczi] = find(pbc <= 0, 1 );
    if ~isempty(pbczi)
        pbc(pbczi) = 0;
        pbc(3-pbczi) = 1;
        p = p12a(3-pbczi,:);
    end
    
    [~,qbczi] = find(qbc <= 0, 1 );
    if ~isempty(qbczi)
        qbc(qbczi) = 0;
        qbc(3-qbczi) = 1;
        q = q12a(3-qbczi,:);
    end
    
    
    
    
    
%     [doesIntersectP,p,pbc] = lineIntersection( p12(1,:)', p12(2,:)', r', (r+d)', true );
%     if pbc(1) <= 0
%         pbc = [0 1];
%     elseif pbc(2) <= 0
%         pbc = [1 0];
%     end
%     [doesIntersectQ,q,qbc] = lineIntersection( q12(1,:)', q12(2,:)', r', (r+d)', true );
%     if qbc(1) <= 0
%         qbc = [0 1];
%     elseif qbc(2) <= 0
%         qbc = [1 0];
%     end
    
    p = [p 0] * rotmat';
    q = [q 0] * rotmat';
end

function [pbc,qbc,p,q] = testLine( p12, q12, r, d )
    r1 = r';
    r2 = (r+d)';
    [doesIntersectP,p,pbc] = lineIntersection( p12(1,:)', p12(2,:)', r1, r2, true );
    if pbc(1) <= 0
        pbc = [0 1];
    elseif pbc(2) <= 0
        pbc = [1 0];
    end
    [doesIntersectQ,q,qbc] = lineIntersection( q12(1,:)', q12(2,:)', r1, r2, true );
    if qbc(1) <= 0
        qbc = [0 1];
    elseif qbc(2) <= 0
        qbc = [1 0];
    end
end

