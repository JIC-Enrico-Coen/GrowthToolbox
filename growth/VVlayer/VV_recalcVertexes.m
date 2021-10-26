function vvlayer = VV_recalcVertexes( vvlayer )
%vvlayer = VV_recalcVertexes( vvlayer )
%   Given correct values for the positions of cell wall junctions and cell
%   centres, calculate the positions of all the VV vertexes.

    numcells = length(vvlayer.vcells);
    numedges = size(vvlayer.vvcc,1);
    numwallsegs = sum(vvlayer.wallsegs);
    numvxW = numwallsegs;
    numvxM = numvxW + sum(vvlayer.wallsegs(vvlayer.vvcc(:,4) ~= 0));

    vvlayer.vvptsC = zeros( numcells, 3 );
    for i=1:numcells
        c = vvlayer.vcells{i};
        vvlayer.vvptsC(i,:) = sum(vvlayer.mainvxs(c,:))/length(c);
    end
    
    vvptsW = zeros( numvxW, 3 );
    vvptsM = zeros( numvxM, 3 );

    foo = 0.25;
    vwi = 0;
    vmi = 0;
    for i=1:numedges
        n = vvlayer.wallsegs(i);
        v1 = vvlayer.vvcc(i,1);
        v2 = vvlayer.vvcc(i,2);
        c1 = vvlayer.vvcc(i,3);
        b = ((1:n)' - 0.5)/n;
        a = 1-b;
        vvptsW((vwi+1):(vwi+n),:) = a*vvlayer.mainvxs(v1,:) + b*vvlayer.mainvxs(v2,:);
        vvptsM((vmi+1):(vmi+n),:) = vvptsW((vwi+1):(vwi+n),:)*(1-foo) + repmat( vvlayer.vvptsC(c1,:), n, 1 )*foo;
        vmi = vmi+n;
        c2 = vvlayer.vvcc(i,4);
        if c2 ~= 0
            vvptsM((vmi+1):(vmi+n),:) = vvptsW((vwi+1):(vwi+n),:)*(1-foo) + repmat( vvlayer.vvptsC(c2,:), n, 1 )*foo;
            vmi = vmi+n;
        end
        vwi = vwi+n;
    end
    vvlayer.vvptsW = vvptsW;
    vvlayer.vvptsM = vvptsM;

    % vvlayer.vxLengthsMM stored for each membrane segment the length of that
    % segment.
    vvlayer.vxLengthsMM = sqrt( sum( (vvlayer.vvptsM( vvlayer.edgeMM(:,1), : ) - vvlayer.vvptsM( vvlayer.edgeMM(:,2), : )).^2, 2 ) );
    % vvlayer.vxLengthsM stores for each membrane vertex the length of
    % membrane associated to that vertex.  This is the sum of half the
    % lengths of the membrane segments on either side.
    vvlayer.vxLengthsM = sum(vvlayer.vxLengthsMM(vvlayer.Medgeedge),2)/2;

    % Need to also construct vvlayer.vxLengthsW.
    % For each wall vertex, take the average of the membrane lengths of the
    % two membrane vertexes it connects to.
    vvlayer.vxLengthsW = sqrt( sum( (vvlayer.vvptsW( vvlayer.edgeWW(:,1), : ) - vvlayer.vvptsW( vvlayer.edgeWW(:,2), : )).^2, 2 ) );
end
