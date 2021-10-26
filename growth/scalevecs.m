function vs = scalevecs( vs, len )
%vs = scalevecs( v, len )
%   Scale the row vectors in vs so that the longest has length len.
    
    ns = norms(vs);
    maxn = max(ns);
    if maxn > 0
        scale = len/maxn;
        for i=1:length(ns)
            if ns(i) > 0
                vs(i,:) = vs(i,:) * scale;
            end
        end
    end
end
