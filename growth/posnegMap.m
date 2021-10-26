function c = posnegMap( range, negcolors, poscolors, nsteps )
%c = posnegMap( range, negcolors, poscolors, nsteps )
%   Create a list of colours for use as a colour mapping.

    if range(1)==range(2)
        c = [1 1 1
             1 1 1];
        return;
    end
    
    if (nargin < 4) || isempty(nsteps)
        nsteps = 50;
    end
    
    if length(range)==2
        zrange = [ extendToZero( range ) 0 ];
    else
        zrange = range;
    end
    
    negfrac = min( 1, max( 0, (zrange(1)-zrange(3))/(zrange(1)-zrange(2)) ) );
    posfrac = min( 1, max( 0, (zrange(2)-zrange(3))/(zrange(2)-zrange(1)) ) );
    nneg = ceil(negfrac*nsteps);
    npos = ceil(posfrac*nsteps);
    maxfrac = max(negfrac,posfrac);
    negfrac = negfrac/maxfrac;
    posfrac = posfrac/maxfrac;
    if nneg==0
        posmap = makeCmap( poscolors, npos, posfrac );
        c = posmap;
    elseif npos==0
        c = makeCmap( negcolors(end:-1:1,:), nneg, negfrac );
    else
        negmap = makeCmap( negcolors, nneg, negfrac );
        posmap = makeCmap( poscolors, npos, posfrac );
        c = [ negmap(end:-1:2,:);
              posmap ];
    end
end
