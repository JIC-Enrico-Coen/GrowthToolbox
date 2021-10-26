function chains = makechains3( r, mode )
%chains = makechains3( r, mode )
%   r is an N*(2+E) matrix.  Each row [v1 v2 ...] represents an edge of a graph.
%   The vertexes are v1 and v2, and the remaining E values are data about the
%   edge.  Vertex labels are taken to be unique, i.e. the same vertex label
%   identifies the same vertex whenever it appears.  The edge data do not
%   have to be unique.
%
%   makechains3 decomposes the graph into a set of maximally long paths or
%   cycles.  If mode is 'edges' (the default) then every edge will occur on
%   exactly one path, and every vertex on at least one path.  If mode is
%   'nodes', then every vertex will occur on exactly one path, and every
%   edge on at most one path. Edges can be followed in either direction.
%
%   r can also have size N*2, in which case the edge labels will be 1:N.
%
%   The result is a cell array of K*(3+E) arrays, each one representing a
%   maximally long path or cycle.  The first column of such an array p is
%   the list of vertexes. The second column is a list of edges in the
%   cycle: for i<K, p(i,2) is an edge connecting p(i,1) with p(i+1,1).
%   p(K,2) is zero for an open-ended path of the index of an edge
%   connecting p(K,1) to p(1,1).  The third column is the sense of the edge:
%   p(i,3)==1 if the edge p(i,2) goes from p(i,1) to p(i+1,1), 0 if the
%   reverse.  For an open ended path, p(K,3)==0.  The remaining columns are
%   the edge data for the edge, or zero for p(K,4:end) in an open path.
%
%   If there is more than one edge between the same two vertexes, an
%   arbitrary one of them will be selected and the rest ignored.

    chains = {};

    if isempty(r)
        return;
    end
    
    if nargin < 2
        mode = 'edges';
    end
    
    alledges = strcmp( mode, 'edges' );
    
    vv = r(:,[1 2]);
    e = r(:,3:end);
    edgedatasize = size(e,2);
    
    vvs = sort(vv,2);
    [vvu,iae,~] = unique(vvs,'rows');
    e = e(iae,:);
    % vvs == vv(ia,:)
    % vv == vvs(ic,:)
    [vxis,~,icv] = unique(vvu(:));
    % vxis == vvs(iav)
    % vvs == reshape(vxis(icv),[],2);
    vvsr = reshape(icv,[],2);
    
    adjacency = zeros( length(vxis) );
    adjacency( sub2ind( size(adjacency), vvsr(:), [vvsr(:,2); vvsr(:,1)] ) ) = repmat( (1:length(vxis))', 2, 1 );
    vxdegree = sum(adjacency,1);

    cycle = zeros(10,3+edgedatasize);
    ci = 0;
    beginNewCycle();
    while true
        yy = find(adjacency(xx,:),1);
        if isempty(yy)
            if reversed
                storeCycle();
                % start a new cycle
                if ~beginNewCycle()
                    break;
                end
            else
                reversed = true;
%                 cycle(1:ci,:) = [ cycle(ci:-1:1,1), cycle([(ci-1):-1:1 ci],2), [1-cycle((ci-1):-1:1,3:end); zeros(1,edgedatasize)] ];
                cycle(1:ci,:) = [ cycle(ci:-1:1,1), ...
                                  [cycle((ci-1):-1:1,2); 0], ...
                                  [1-cycle((ci-1):-1:1,3); 0], ...
                                  [cycle((ci-1):-1:1,4:end); zeros( 1, edgedatasize )] ];
                xx = cycle(ci,1);
            end
        else
            edge = adjacency(xx,yy);
            cycle(ci,2:end) = [edge, vxis(cycle(ci,1))==vv(iae(edge),1), e(edge,:)];
            if alledges
                adjacency(xx,yy) = 0;
                adjacency(yy,xx) = 0;
                vxdegree([xx yy]) = vxdegree([xx yy])-1;
            else
                adjacency([xx yy],:) = 0;
                adjacency(:,[xx yy]) = 0;
                vxdegree([xx yy]) = 0;
            end
            if yy==cyclestart
                storeCycle();
                if ~beginNewCycle()
                    break;
                end
            else
                ci = ci+1;
                if ci > size(cycle,1)
                    % Need more space: make the array twice as long.
                    cycle(2*end,1) = 0;
                end
                cycle(ci,1) = yy;
                xx = yy;
            end
        end
    end
    
    function storeCycle()
        chains{end+1} = [ vxis(cycle(1:ci,1)), cycle(1:ci,2:end) ];
        nzrows = sum(adjacency,1) > 0;
        adjacency = adjacency(nzrows,nzrows);
        vxis = vxis(nzrows);
    end
    
    function ok = beginNewCycle()
        [xx,yy] = ind2sub( size(adjacency), find(adjacency,1) );
        ok = ~isempty(xx);
        if ok
            edge = adjacency(xx,yy);
            cycle(1:2,:) = [yy, edge, (vxis(yy)==vv(iae(edge))),  e(edge,:); xx zeros( 1, edgedatasize+2 )];
            ci = 2;
            cyclestart = yy;
            adjacency(xx,yy) = 0;
            adjacency(yy,xx) = 0;
            reversed = false;
        end
    end
end
