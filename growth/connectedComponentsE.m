function [nodeindexes,nodesets,edgeindexes,edgesets,cellindexes,cellsets] = connectedComponentsE( m )
%[nodeindexes,nodesets,edgeindexes,edgesets,cellindexes,cellsets] = connectedComponentsE( m )
%   Find the connected components of m by following the edges.
%   nodeindexes will be an array mapping each node to the index of its
%   component, and nodesets will be a cell array of the connected
%   components.  For every node n, n occurs in nodesets{nodeindexes(n)}.

    numnodes = size(m.nodes,1);
    nodeindexes = zeros(numnodes,1);
    nodesets = {};
    for i=1:numnodes
        if nodeindexes(i)==0
            curcpt = length(nodesets)+1;
            cpt = [];
            unprocessed = [i];
            while ~isempty(unprocessed)
                nodeindexes(unprocessed) = curcpt;
                cpt = [ cpt; unprocessed ];
                nbs = [];
                for j=1:length(unprocessed)
                    nce = m.nodecelledges{unprocessed(j)};
                    ne = nce(1,:);
                    n = m.edgeends(ne,:);
                    nbs = [nbs; n(:)];
                end
                nbs = unique(nbs);
                nbs = nbs(nodeindexes(nbs)==0);
                unprocessed = nbs;
            end
            nodesets{curcpt} = cpt;
        end
    end
    edgeindexes = nodeindexes(m.edgeends(:,1));
    cellindexes = nodeindexes(m.tricellvxs(:,1));
    edgesets = partitionlist( edgeindexes );
    cellsets = partitionlist( cellindexes );
end

