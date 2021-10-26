function nodeareas = calcnodeareas( m )
% nodeareas = calcnodeareas( m )
%   For each node, calculate the area of all of the cells containing that
%   node.

    nodeareas = zeros(1:size(m.nodes,2));
    for i=1:length(m.nodecelledges)
        nce = m.nodecelledges{i};
        nodeareas(i) = sum(m.cellareas(nce(1,:)));
    end
end
