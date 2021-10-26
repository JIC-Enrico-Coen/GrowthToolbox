function [vs,es,perms] = getMeshBorders( m )
    borderedges = m.edgecells(:,2)==0;
    ev = m.edgeends(borderedges,:);
    if isempty(ev)
        vs = {};
        es = {};
        perms = {};
        return;
    end
    ec = m.edgecells(borderedges,1);
    ecvxs = m.tricellvxs(ec,:);
    parity = all( ecvxs(:,[1 2])==ev, 2 ) ...
             | all( ecvxs(:,[2 3])==ev, 2 ) ...
             | all( ecvxs(:,[3 1])==ev, 2 );
    ev(~parity,:) = ev(~parity,[2 1]);
    [vs,perms] = makeloops( ev(:,1), ev(:,2) );
    bei = int32(find(borderedges));
    for i=1:length(perms)
        es{i} = bei(perms{i});
    end
end
