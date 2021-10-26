function m1 = splitcornertouch( m )
%m1 = splitcornertouch( m )
%   Wherever there is a node that belongs to cells that share no edges,
%   split that node into as many copies as it takes to eliminate such
%   corner contacts.

% Find the edges which have a cell on only one side.
    borderedges = find(m.edgecells(:,2)==0);

% Construct an N*2 array in which each row contains a node and
% a border edge the node belongs to.
    nodeedges = sortrows( [ [ m.edgeends(borderedges,1) borderedges ]; ...
                            [ m.edgeends(borderedges,2) borderedges ] ] );
    nodeedges = [ nodeedges; [0 0] ];  % Sentinel.

% Walk down nodeedges, seeing which nodes belong to four or more border
% edges.  These are the nodes that must be split.
    a = nodeedges(1,1);
    b = 1;
    splitnodes = [];
    numcopies = [];
    splitedgesets = {};
    ns = 0;
    for i=2:size(nodeedges,1)
        a1 = nodeedges(i,1);
        if a==a1
            b = b+1;
        else
            if b >= 4
                ns = ns+1;
                splitnodes(ns) = nodeedges(i-1,1);
                numcopies(ns) = b/2;
                splitedgesets{ns} = nodeedges(i-b:i-1,2);
            end
            a = a1;
            b = 1;
        end
    end
    
    m1 = m;

    if ns==0
        % Nothing to split.
        fprintf( 1, '%s: no nodes found to split.\n', mfilename() );
        return;
    end
    
    newnode = size(m.nodes,1);
% For each node...
    for i=1:ns
        % Determine the clumps of connected cells and edges it belongs to.
        % For each clump after the first, replace the node by a new node
        % in the cells and edges of the clump.
        ni = splitnodes(i);
        eis = splitedgesets{i};
        eb = ones(1,length(eis));
        numClumps = 0;
        clumps = {};
        for i=1:length(eis)
            if eb(i)
                % New border edge.
                curEdge = eis(i);
                curCell = m.edgecells(curEdge,1);
                clump = [ curEdge, curCell ];
                while curCell ~= 0
                    [curEdge,curCell] = findNextEdgeAndCell( m, curCell, curEdge, ni );
                    clump( size(clump,1)+1, : ) = [ curEdge, curCell ];
                end
                eb(eis==curEdge) = 0;
                numClumps = numClumps+1;
                clumps{numClumps} = clump;
              % clump
            end
        end
        for i=2:length(clumps)
            clump = clumps{i};
            % Duplicate the node.
            newnode = newnode+1;
            m1.nodes(newnode,:) = m.nodes(ni,:);
            m1.morphogens(newnode,:) = m.morphogens(ni,:);
            m1.morphogenclamp(newnode,:) = m.morphogenclamp(ni,:);
            m1.prismnodes((newnode+newnode)+[-1 0],:) = ...
                m.prismnodes((ni+ni)+[-1 0],:);
            % Insert the new node into the edges.
            for j=1:size(clump,1)
                ei = clump(j,1);
                m1.edgeends(ei,m.edgeends(ei,:)==ni) = newnode;
            end
            % Insert the new node into the cells.
            for j=1:size(clump,1)-1
                ci = clump(j,2);
                m1.tricellvxs(ci,m.tricellvxs(ci,:)==ni) = newnode;
            end
        end
    end

    validmesh(m1);
end
