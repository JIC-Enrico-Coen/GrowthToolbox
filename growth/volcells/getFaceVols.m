function fv = getFaceVols( volcells )
%fv = getFaceVols( volcells )
%   Return an N*2 array listing for every face the up to two volumes it
%   belongs to. Where it belongs to only one, the second index is 0.

    numvols = length(volcells.polyfaces);
    if numvols==0
        fv = zeros( length(volcells.facevxs), 2, 'uint32' );
        return;
    end
    facesPerVol = zeros( numvols, 1 );
    for ci=1:numvols
        facesPerVol(ci) = length(volcells.polyfaces{ci});
    end
    vf = zeros( sum(facesPerVol), 2 );
    vfi = 0;
    for ci=1:numvols
        fs = volcells.polyfaces{ci};
        nfs = length(fs);
        vf( (vfi+1):(vfi+nfs), 1 ) = fs;
        vf( (vfi+1):(vfi+nfs), 2 ) = ci;
        vfi = vfi+nfs;
    end
    vf = sortrows( vf );
    c2 = [false;vf(1:(end-1),1)==vf(2:end,1)];
    c1 = ~c2;
    numfaces = length( volcells.facevxs );
    fv = zeros(numfaces,2);
    fv(vf(c1,1),1) = vf(c1,2);
    fv(vf(c2,1),2) = vf(c2,2);
end
