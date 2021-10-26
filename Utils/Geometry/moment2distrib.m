function [mom2,centroid,total] = moment2distrib( nodes, tricellvxs, values, centre )
%[mom2,centroid] = moment2distrib( nodes, tricellvxs, values, centre )
%   NODEs is an N*3 array, containing the vertex positions of a mesh.
%   TRIANGLES is an M*3 array of triples of node indexes, defining the
%   triangles of the mesh.
%   VALUES is an N*1 array of values defined at each vertex.
%   CENTRE is a point, by default the centroid of the distribution.
%   Consider VALUES to define the distribution of concentration os a
%   substance over the mesh, linearly interpolated over every triangle.
%
%   Results:
%   MOM2 will be the second moment of that distribution about the centre.
%   CENTROID (if asked for) will be the centroid of the distribution.  If
%   CENTRE is omitted it will default to the centroid; in  that case MOM2
%   is the variance of the distribution.
%   TOTAL (if asked for) will be the total quantity of the distribution.
%
%   See also: meanpos.

    areas = triangleareas( nodes, tricellvxs );
    total = sum( sum( values( tricellvxs ) .* repmat( areas, 1, 3 ), 2 ), 1 )/3;
    
    if (nargin < 4) || (nargout > 1)
        trianglevertexes = reshape( nodes( tricellvxs', : ), 3, [], 3 );
        % Indexes are triangle, vertex, coordinate.
        trianglevalues = repmat( values( tricellvxs' ) .* repmat( areas', 3, 1 ), [1, 1, 3] );
        centroid = permute( sum( sum( trianglevertexes .* trianglevalues, 2 ), 1 ), [1, 3, 2] )/(3*total);
    end
    if nargin < 4
        centre = centroid;
    else
        nodes = nodes - repmat( centre, size(nodes,1), 1 );
    end
    mom2 = 0;

    K30 = 1/K(3,0);
    K21 = 1/K(2,1);
    K12 = 1/K(1,2);
    K03 = 1/K(0,3);
    K20 = 1/K(2,0);
    K11 = 1/K(1,1);
    K02 = 1/K(0,2);
    K10 = 1/K(1,0);
    K01 = 1/K(0,1);
    K00 = 1/K(0,0);
    trivals = values(tricellvxs);
    
    trivxs = reshape( nodes(tricellvxs',:), 3, [], 3 ); % vx, tri, coord
    vvsq = sum( trivxs.^2, 3 )';
    vvcross = sum( trivxs([3 1 2],:,:).*trivxs([2 3 1],:,:), 3 )';
    vv11 = vvsq(:,1)+vvsq(:,3)-2*vvcross(:,2);
    vv22 = vvsq(:,2)+vvsq(:,3)-2*vvcross(:,1);
    vv33 = vvsq(:,3);
    vv12 = vvsq(:,3)-vvcross(:,1)-vvcross(:,2)+vvcross(:,3);
    vv13 = vvcross(:,2)-vvsq(:,3);
    vv23 = vvcross(:,1)-vvsq(:,3);
    if true
        % Vectorised.
        Q20 = vv11;
        Q11 = vv12*2;
        Q02 = vv22;
        Q10 = vv13*2;
        Q01 = vv23*2;
        Q00 = vv33;
        L10 = trivals(:,1)-trivals(:,3);
        L01 = trivals(:,2)-trivals(:,3);
        L00 = trivals(:,3);
        C30 = K30*Q20.*L10;
        C21 = K21*(Q20.*L01 + Q11.*L10);
        C12 = K12*(Q11.*L01 + Q02.*L10);
        C03 = K03*Q02.*L01;
        C20 = K20*(Q20.*L00 + Q10.*L10);
        C11 = K11*(Q11.*L00 + Q01.*L10 + Q10.*L01);
        C02 = K02*(Q02.*L00 + Q01.*L01);
        C10 = K10*(Q10.*L00 + Q00.*L10);
        C01 = K01*(Q01.*L00 + Q00.*L01);
        C00 = K00*Q00.*L00;
        mom2 = 2*sum( areas.*(C30+C21+C12+C03+C20+C11+C02+C10+C01+C00) );
    else
        % Non-vectorised.  About 1/3 the speed of the vectorised code for a
        % mesh of 1200 elements. 
        allL10 = trivals(:,1)-trivals(:,3);
        allL01 = trivals(:,2)-trivals(:,3);
        allL00 = trivals(:,3);
        for i=1:size(tricellvxs,1)
            v = nodes(tricellvxs(i,:),:);
            vals = trivals(i,:);
            r = [ [1 0 -1]; [0 1 -1]; [0 0 1] ];
            vv1 = v*v';
            vv = r*v*v'*r';
          % vvXX = [ vv11(i) vv12(i) vv13(i); vv12(i) vv22(i) vv23(i); vv13(i) vv23(i) vv33(i) ]
            Q20 = vv11(i); % vv(1,1);
            Q11 = vv(1,2)+vv(2,1);
            Q02 = vv22(i); % vv(2,2);
            Q10 = vv(3,1)+vv(1,3);
            Q01 = vv(3,2)+vv(2,3);
            Q00 = vv33(i); % vv(3,3);
            L10 = allL10(i); % vals(1)-vals(3);
            L01 = allL01(i); % vals(2)-vals(3);
            L00 = allL00(i); % vals(3);
            C30 = K30*Q20*L10;
            C21 = K21*(Q20*L01 + Q11*L10);
            C12 = K12*(Q11*L01 + Q02*L10);
            C03 = K03*Q02*L01;
            C20 = K20*(Q20*L00 + Q10*L10);
            C11 = K11*(Q11*L00 + Q01*L10 + Q10*L01);
            C02 = K02*(Q02*L00 + Q01*L01);
            C10 = K10*(Q10*L00 + Q00*L10);
            C01 = K01*(Q01*L00 + Q00*L01);
            C00 = K00*Q00*L00;
            a = areas(i);
            mom2 = mom2 + 2*a*(C30+C21+C12+C03+C20+C11+C02+C10+C01+C00);
        end
    end
    mom2 = mom2/total;
end

function k = K(i,j)
% 1/k is the result of integrating x^i y^j over the triangle bounded by x >= 0, y
% >= 0, x+y <= 1.

    k = (i+j+1)*(i+j+2)*combinations(i+j,j);
end

