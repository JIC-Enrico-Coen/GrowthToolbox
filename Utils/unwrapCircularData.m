function c = unwrapCircularData( c, period, dim )
    if isempty(c)
        return;
    end
    
    sz = size(c);
    sz( (length(sz)+1):dim ) = 1;
    szbefore = sz(1:(dim-1));
    szafter = sz((dim+1):end);
    szdim = sz(dim);
    c = reshape( c, [ prod(szbefore), szdim, prod(szafter) ] );
    
    for cibefore=1:prod(szbefore)
        for ciafter=1:prod(szafter)
            steps = c(cibefore,2:end,ciafter) - c(cibefore,1:(end-1),ciafter);
            jumps = zeros(size(steps));
            jumps(steps>period/2) = -period;
            jumps(steps<-period/2) = period;
            c(cibefore,:,ciafter) = c(cibefore,:,ciafter) + [0, cumsum(jumps)];
        end
    end
%     c = c(:);
%     steps = c(2:end)-c(1:(end-1));
%     jumps = zeros(size(steps));
%     jumps(steps>period/2) = -period;
%     jumps(steps<-period/2) = period;
%     c = c + [0; cumsum(jumps)];
    c = reshape( c, sz );
end