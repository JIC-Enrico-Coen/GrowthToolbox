function vertexValues = diffuseRandomField( vxs, radius, gridspacing )
%vertexValues = diffuseRandomField( vxs, radius, gridspacing )
%
%   Assign a random value to each of the points in the N*D array VXS.
%   The values are uniformly distributed between 0 and 1, and are diffused
%   throughout the volume until they have a characteristic radius of
%   RADIUS.
%
%   GRIDSPACING specifies the spacing of the points of a rectangular or
%   cuboidal grid enclosing the whole of the set of vertexes. Diffusion
%   takes place on this grid. The values are then interpolated to give
%   values at the vertexes.

    minvxs = min(vxs);
    maxvxs = max(vxs);
    
    numboxes = ceil( (maxvxs-minvxs)/gridspacing );
    numvxs = numboxes+1;
    numpasses = round( (radius/gridspacing)^2 );
    
    if numpasses < 1
        vertexValues = rand(size(vxs,1),1);
        return;
    end
    
    gridvals = rand( numvxs );
    numdims = size(vxs,2);
    filterval = gridspacing^2/(2*numdims);
    filtersize = 1 + 2*numpasses;
    filter0 = zeros( [filtersize filtersize filtersize] );
    e1 = numpasses;
    e2 = e1+1;
    e3 = e1+2;
    centreval = 1 - 2*filterval*numdims;
    switch numdims
        case 1
            filter0([e1 e3]) = filterval;
            filter0(e2) = centreval;
        case 2
            filter0([e1 e3],e2) = filterval;
            filter0(e2,[e1 e3]) = filterval;
            filter0(e2,e2) = centreval;
        case 3
            filter0([e1 e3],e2,e2) = filterval;
            filter0(e2,[e1 e3],e2) = filterval;
            filter0(e2,e2,[e1 e3]) = filterval;
            filter0(e2,e2,e2) = centreval;
    end
    
    filter = filter0;
    for i=1:numpasses
        filter = imfilter( filter, filter0, 0 );
    end
    
    gridvalsf = imfilter( gridvals, filter, 0 );
    
    gridsemidiam = (numboxes/2)*gridspacing;
    midvxs = (minvxs+maxvxs)/2;
    mingrid = midvxs - gridsemidiam;
    vxsingrid = vxs - mingrid;
    
    whereinbox = mod( vxsingrid, gridspacing );
    whichbox = floor( vxsingrid/gridspacing ) + 1;
    
    whichboxi = sub2ind( size(gridvalsf), whichbox(:,1), whichbox(:,2), whichbox(:,3) );
    d1 = size(gridvalsf,1);
    d12 = d1 * size(gridvalsf,2);
    whichcorners = whichboxi + [ 0, 1, d1, 1+d1, d12, 1+d12, d1+d12, 1+d1+d12 ];
    vertexValues = gridvalsf( whichcorners );
    vertexValues = vertexValues(:,[1 3 5 7]).*(1 - whereinbox(:,1)) + vertexValues(:,[2 4 6 8]).*whereinbox(:,1);
    if numdims > 1
        vertexValues = vertexValues(:,[1 3]).*(1 - whereinbox(:,2)) + vertexValues(:,[2 4]).*whereinbox(:,2);
        if numdims > 2
            vertexValues = vertexValues(:,1).*(1 - whereinbox(:,3)) + vertexValues(:,2).*whereinbox(:,3);
        end
    end
end
