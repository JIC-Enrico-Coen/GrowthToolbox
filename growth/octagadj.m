function mesh = octagadj(l)
%MESH = OCTAGADJ(L) Create connection graph of trangulated octagon.
%  L is the radius of the octagon.
    outeri = (0:1/8:1)*pi*2;
    outerx = cos(outeri)*l;
    outery = sin(outeri)*l;
    inneri = (0:1/4:1)*pi*2;
    innerx = cos(inneri)*l/2;
    innery = sin(inneri)*l/2;
    xs = [ outerx(1:8), innerx(1:4) ];
    ys = [ outery(1:8), innery(1:4) ];
%    zs = randn(1,length(xs))*0.02;
    zs = (xs.^2 + ys.^2);
    maxzs = max(zs);
    if (maxzs > 0)
        zs = (maxzs - zs)/maxzs;
    end
    zs = zs*0.1;
    as1 = [ 1:12,             9:12,  9:12,  9:12,     9 ];
    as2 = [ 2:8, 1, 10:12, 9, 1:2:7, 2:2:8, 8, 2:2:6, 11 ];
    dsqs = (xs(as2(:)) - xs(as1(:))).^2 ...
            + (ys(as2(:)) - ys(as1(:))).^2 ...
            + (zs(as2(:)) - zs(as1(:))).^2;
    ds = sqrt(dsqs);
    mesh.nodes = [ xs', ys', zs' ];
    mesh.globalProps.activeGrowth = 1;
    mesh.globalProps.displayedGrowth = 1;
    mesh.morphogens(:,mesh.globalProps.activeGrowth) = zs*0.1;
    mesh.morphogenclamp = zeros(size(mesh.morphogens));
    mesh.edgeends = [ as1', as2' ];
    mesh.edgelinsprings = [ dsqs', ds', ds', ones(length(as1),1) ];
    mesh.edgecells(:,1) = [ 1:8,        9:12,           1:2:7,    1:2:7, 8, 2:2:6, 13 ]';
    mesh.edgecells(:,2) = [ zeros(1,8), 13, 13, 14, 14, 8, 2:2:6, 9:12,  12, 9:11, 14 ]';
    mesh.edgehinges(:,1:3) = zeros(25,3);
    mesh.tricellvxs = zeros(3,14);
    mesh.tricellvxs(:,1) = [ 1:8, 2:2:8, 9, 11 ]';
    mesh.tricellvxs(:,2) = [ 2:8, 1 10:12, 9, 10, 12 ]';
    mesh.tricellvxs(:,3) = [ 9,10,10,11,11,12,12,9, 9:12, 11, 9 ]';
    mesh.celledges = zeros(14,3);
    mesh.celledges(:,1) = [ 17, 14, 18, 15, 19, 16, 20, 13, 9:12, 10, 12 ]';
    mesh.celledges(:,2) = [ 13, 22, 14, 23, 15, 24, 16, 21, 17:20, 25, 25 ]';
    mesh.celledges(:,3) = [ 1:8, 22:24, 21, 9, 11 ]';
end

