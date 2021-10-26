function cutpolygon = planeVolumeIntersection( vxs, tricellvxs, cuttingPoint, cuttingNormal )
%planeVolumeIntersection( vxs, tricellvxs, cuttingPoint, cuttingNormal )
% Find the intersection between a plane and a closed triangular mesh.
% vxs: N*3 array of N points.
% tricellvxs: T*3 array of triples of vertex indexes.
% cuttingPoint: 1*3 position of a point on the cutting plane.
% cuttingNormal: 1*3 vector perpendicular to the cutting plane.
%
%   USED ONLY BY plane3DMeshIntersection, WHICH IS NEVER USED.  MAY NOT
%   WORK BECAUSE OF PROBLEM IN SPLITINTS APPLIED TO MULTIPLE INTEGERS.

    % Rotate everything to bring the cuttingPoint to [0 0 0] and
    % cuttingNormal to [1 0 0].
    cuttingNormal = cuttingNormal/norm(cuttingNormal);
    [vy,vz] = makeframe( cuttingNormal );
    rot = [cuttingNormal;vy;vz];
    vxs1 = (vxs - repmat( cuttingPoint, size(vxs,1), 1 )) * rot';
    posvxs = vxs1(:,1) >= 0;
    postri = posvxs(tricellvxs);
    
    
    
    
    crossing23 = postri(:,2) ~= postri(:,3);
    crossing31 = postri(:,3) ~= postri(:,1);
    crossing12 = postri(:,1) ~= postri(:,2);
    splittris = crossing23 | crossing31 | crossing12;
    splittricellvxs = tricellvxs(splittris,:);
    
    % Eliminate redundant vertexes.
    [uvxs,ia,ic] = unique( splittricellvxs );
    vxs = vxs(uvxs,:);
    renumbervxs = zeros(1,max(uvxs));
    renumbervxs(uvxs) = 1:length(uvxs);
    splittricellvxs = reshape( renumbervxs( splittricellvxs ), size(splittricellvxs) );
    % This transformation leaves vxs(splittricellvxs,:) unchanged.
    % The reason for eliminating redundant vertexes is to reduce the
    % maximum vertex index, helping to avoid uses of pairInts that might
    % overflow the bounds of 32-bit integer arithmetic.
    
    
    
%     splittriedges = reshape( 1:(3*size(splittricellvxs,1)), [], 3 );
    crossing23 = crossing23(splittris);
    crossing31 = crossing31(splittris);
    crossing12 = crossing12(splittris);
    crossings = [ crossing23, crossing31, crossing12 ];
    numtris = size(splittricellvxs,1);
    
    % Get the vertex pairs for all the crossing edges
    vv = [ find(crossing23),           splittricellvxs(crossing23,[2 3]); ...
           find(crossing31)+numtris,   splittricellvxs(crossing31,[3 1]); ...
           find(crossing12)+numtris*2, splittricellvxs(crossing12,[1 2]) ];
    % Encode them as single integers.
    nn = (1:numtris)';
    e1 = pairInts( splittricellvxs(:,[2 3]), true );
    e2 = pairInts( splittricellvxs(:,[3 1]), true );
    e3 = pairInts( splittricellvxs(:,[1 2]), true );
    vv1 = splitInts(e1);
    vv2 = splitInts(e2);
    vv3 = splitInts(e3);
    bc1 = makebc( reshape( vxs( vv1', 1 ), 2, [] )' );
    bc2 = makebc( reshape( vxs( vv2', 1 ), 2, [] )' );
    bc3 = makebc( reshape( vxs( vv3', 1 ), 2, [] )' );
    vxs1 = vxs(vv1(:,1),:) .* repmat(bc1,1,3)  +  vxs(vv1(:,2),:) .* repmat((1-bc1),1,3);
    vxs2 = vxs(vv2(:,1),:) .* repmat(bc2,1,3)  +  vxs(vv2(:,2),:) .* repmat((1-bc2),1,3);
    vxs3 = vxs(vv3(:,1),:) .* repmat(bc3,1,3)  +  vxs(vv3(:,2),:) .* repmat((1-bc3),1,3);
    vxs123 = [vxs1; vxs2; vxs3];
    
    
    
    
    
    
%     edgetris = [ [ e2(~crossing23), e3(~crossing23), nn(~crossing23), bc2(~crossing23), bc3(~crossing23) ]; ...
%               [ e3(~crossing31), e1(~crossing31), nn(~crossing31), bc3(~crossing31), bc1(~crossing31) ]; ...
%               [ e1(~crossing12), e2(~crossing12), nn(~crossing12), bc1(~crossing12), bc2(~crossing12) ] ];
    edgetris = [ [ e2(~crossing23), e3(~crossing23), vxs2(~crossing23,:), bc2(~crossing23) ]; ...
              [ e3(~crossing31), e1(~crossing31), vxs3(~crossing31,:), bc3(~crossing31) ]; ...
              [ e1(~crossing12), e2(~crossing12), vxs1(~crossing12,:), bc1(~crossing12) ] ];
    edgesused = reshape( [crossing23; crossing31; crossing12], [], 3 );
    chains = makechains3( edgetris );
    c = chains{1};
    % The columns of c are:
    % 1: edges of the mesh, encoded as pairs of vertexes.
    % 2: indexes of triangles in splittricellvxs.
    % 3: The sense in which the trianglehas been followed from one edge to
    % the other.
    % 4-6: The cutting point on the edge indicated in column 1.
    % 7: The first barycentric coordinate of the cutting point.
    
    cutpolygon = c(:,4:6); % This is the intersection polygon.
    bca = c(:,7);
    bcb = 1-bca;
    edgeends = splitInts( c(:,1) );
    test = vxs(edgeends(:,1),:).*repmat(bca,1,3) + vxs(edgeends(:,2),:).*repmat(1-bca,1,3);
    % We would also like to know the vertexes and bcs.
end

function bc = makebc( xx )
    bc = xx(:,2)./(xx(:,2) - xx(:,1));
end


