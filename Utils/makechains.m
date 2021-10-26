function [ch,rperm] = makechains( r )
%[ch,rperm] = makechains( r )
%   R is an N*3 matrix representing a labelled relation: the row
%   [c e1 e2] represents an arrow from e1 to e2 labelled c.  The relation
%   is assumed to be either a set of linear chains, or a single cycle.  The
%   result is a representation of the chain as a list of alternate elements
%   and labels, in which the above instance of the relation will appear as
%   subsequence [... e1 c e2 ...].  Where the relation consists of more
%   than one chain, they will be separated from each other in the list by a
%   value of 0 (which is never the value of an element or label).
%   The result will begin with some ei and end with some c.
%
%   The rperm output is a list of indexes into r such that ch(1:2:end) is
%   identical to r(rperm,2).
%
%   If r is an N*2 matrix, it is assumed to contain the [e1 e2] values
%   only.  c will be taken to be 1:N.

    if isempty(r)
        ch = [];
        rperm = [];
        return;
    end
    
    if size(r,2)==2
        r = [ (1:size(r,1))', r ];
    end

    r_offset = min(r(:))-1;
    r = r - r_offset;
    
    relsize = size(r,1);
    items = unique(r(:,[2 3]));
    index = sparse(double(max(items)),1);
    index(items) = 1:length(items);
    r(:,[2 3]) = full(index(r(:,[2 3])));
    maxr = max(max(r(:,[2 3])));
    mx = zeros(maxr,maxr);
    for i=1:relsize
        mx(r(i,2),r(i,3)) = i;
    end
    invalence = sum(mx,1);
    initials = find(invalence==0); % indexes into mx
    if isempty(initials)
        initials = 1;
    end
    ch = zeros(1,0,'like',r);
    chi = 0;
    rperm = zeros(1,0);
    rpi = 0;
    for i=1:length(initials)
        mistart = initials(i);  % index into mx
        mi = mistart;  % index into mx
        mj = find(mx(mi,:),1);  % index into mx
        ri = mx(mi,mj);  % index into r
        chi = chi+1; ch(chi) = items(r(ri,2));
        rpi = rpi+1; rperm(rpi) = ri;
        chi = chi+1; ch(chi) = r(ri,1);
        while mj ~= mistart
            chi = chi+1; ch(chi) = items(r(ri,3));
            mi = mj;
            mj = find(mx(mi,:),1);
            if isempty(mj)
                chi = chi+1; ch(chi) = 0;
                break;
            end
            ri = mx(mi,mj);  % index into r
            rpi = rpi+1; rperm(rpi) = ri;
            chi = chi+1; ch(chi) = r(ri,1);
        end
    end
    ch = reshape(ch,2,[]);
    ch(ch>0) = ch(ch>0) + r_offset;
end
