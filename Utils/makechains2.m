function chains = makechains2( r, mode )
%chains = makechains2( r, mode )
%   R is an N*3 matrix representing a labelled relation: the row
%   [e v1 v2] represents an edge joining vertex v1 and v2 labelled e.
%   Alternatively, R can be N*2, with each row [v1 v2] representing an
%   unlabelled edge.  In this case R will be extended to the first form by
%   adding 1:N as its edge labels. The direction of edges is assumed to be
%   unimportant.
%
%   The result is a representation of the relation as a set of chains, each
%   of which is a K*2 array [v1 e1; v2 e2; ...].  In this array, ei is the
%   label of an edge joining vi and v(i+1) (in either order).  eK is either
%   0 (for an open-ended chain) or the label of an edge joining vK and v1.
%
%   If the mode is 'nodes' (the default), then every vertex will appear on
%   exactly one chain, and every edge will appear on at most one chain.
%   If the mode is 'edges', then every edge will appear on exactly one
%   chain, and every vertex will appear on at least one chain.
%   For relations that consist of a disjoint set of cycles and open-ended
%   chains, both modes give the same result: every vertex and every edge
%   appears on exactly one chain.

    if isempty(r)
        chains = {};
        return;
    end
    
    if nargin < 2
        mode = 'nodes';
    end
    
    if size(r,2)==2
        r = [ (1:size(r,1))', r ];
    end
    
    r_offset = min(min(r(:,[2 3]))-1);
    r(:,[2 3]) = r(:,[2 3]) - r_offset;
    
    items = unique(r(:,[2 3]));
    index = sparse(double(max(items)),1);
    index(items) = 1:length(items);
    r(:,[2 3]) = full(index(r(:,[2 3])));
    
    rr = zeros(length(items),4);
    rr( r(:,2), 1 ) = r(:,3);
    rr( r(:,2), 3 ) = r(:,1);
    rr( r(:,3), 2 ) = r(:,2);
    rr( r(:,3), 4 ) = r(:,1);
% r
% rr
    
    rri = 0;
    chains = {};
    while rri < size(rr,1)
        rri = rri+1;
        c1 = findchain( rri );
        c2 = findchain( rri );
        if isempty(c1)
            c = c2;
        elseif isempty(c2)
            c = c1;
        else
            c = [ c1(end:-1:1,:); [rri,0]; c2 ];
        end
        if ~isempty(c)
            c(c(:,1) ~= 0) = items( c(c(:,1) ~= 0) ) + r_offset;
            chains{end+1} = c;
        end
    end
    
function c = findchain( rri )
    rri0 = rri;
    c = zeros(0,2);
    if all(rr(rri,[1 2])==0)
        return;
    end
    while true
        rrij = find( rr(rri,[1 2]) ~= 0, 1 );
        if isempty(rrij)
            c(end+1,:) = [rri,0];
            break;
        end
        rri2 = rr(rri,rrij);
        e = rr(rri,rrij+2);
        c(end+1,:) = [rri,e];
        rr(rri,rrij) = 0;
        i = find(rr(rri2,[1 2])==rri,1);
        if isempty(i)
            % Should never happen.
            break;
        end
        rr(rri2,i) = 0;
        rr(rri2,i+2) = 0;
        rri = rri2;
        if rri==rri0
            break;
        end
    end
    rr(c(:,1),:) = 0;
end
end

