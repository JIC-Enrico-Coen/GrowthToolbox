function ns = norms( vs )
%ns = norms( vs )
%   Calculate the norms of all the row vectors in vs.

    ns = sqrt(dot(vs,vs,2));
end
