function a = interpolateNans( a, dim, mode )

    if isempty(a)
        return;
    end
    sz = size(a);
    szbefore = prod(sz(1:(dim-1)));
    szafter = prod(sz((dim+1):end));
    a = reshape( a, szbefore, sz(dim), szafter );
    for ai=1:szbefore
        for ci=1:szafter
            d = a(ai,:,ci);
            [v,di] = find( ~isnan( d ), 1 );
            if isempty(di)
                a(ai,1,ci) = 0;
            else
                d(1:(di-1)) = v;
                [starts,ends,vs] = runends( d );
                for vi=1:length(vs)
                    if isnan(vs(vi))
                        d(starts(vi):ends(vi)) = d(starts(vi)-1);
                    end
                end
                a(ai,:,ci) = d;
            end
        end
    end
    a = reshape( a, sz );
end