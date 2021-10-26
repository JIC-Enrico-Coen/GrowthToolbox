function [vs,es,ts,tis,loopperms] = getPolyMeshBorders( tris )
    [edgeends1,rowperms1] = sort( reshape( tris( :, [2 3 3 1 1 2] )', 2, [] )', 2 );
    flipped1 = rowperms1(:,1)==2;
    [edgeends,aeperm] = sortrows( edgeends1 );
    [tvi,ti] = ind2sub( [size(tris,2) size(tris,1)], aeperm );
    parity = flipped1(aeperm,:);
    dupedges = all( edgeends(1:(end-1),:)==edgeends(2:end,:), 2 );
    borderedges = ~([dupedges;false] | [false;dupedges]);
    ev = edgeends(borderedges,:);
    if isempty(ev)
        vs = {};
        es = {};
        ts = {};
        tis = {};
        loopperms = {};
        return;
    end
    bparity = parity(borderedges);
    ev(~bparity,:) = ev(~bparity,[2 1]);
    [vs,loopperms] = makeloops( ev(:,2), ev(:,1) );
    bei = int32(find(borderedges));
    es = cell(1,length(loopperms));
    ts = cell(1,length(loopperms));
    tis = cell(1,length(loopperms));
    for i=1:length(loopperms)
        es{i} = bei(loopperms{i});
        ts{i} = ti(es{i});
        tis{i} = tvi(es{i});
    end
end
