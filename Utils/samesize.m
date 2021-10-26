function same = samesize( a, b )
%same = samesize( a, b )
%   Determine whether sizes A and B are the same.

    la = length(a);
    lb = length(b);
    l = min(la,lb);
    if any( a(1:l) ~= b(1:l) )
        same = false;
    elseif la==lb
        same = true;
    elseif la < lb
        same = all( b( (la+1):lb )==1 );
    else
        same = all( a( (lb+1):la )==1 );
    end
end
