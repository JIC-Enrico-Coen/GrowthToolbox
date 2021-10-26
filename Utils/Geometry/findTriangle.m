function [ ci, bc, bcerr, d, ishint, p1 ] = findTriangle( vxs, tris, normals, p, varargin )
%[ ci, bc, bcerr, abserr, ishint, p1 ] = findTriangle( vxs, tris, normals, p, ... )
%   Find which triangle the point P is closest to lying in.
%
%   The following named options may also be given.
%
%   'hint'  A list of FEs to try first.
%
%   'only'  A boolean, by default false.  If true, only the hint FEs are
%           searched; if false, all FEs are searched. If the hint is empty,
%           this option is ignored.
%
%   'expand'  A boolean, by default false.  If true, and the hint is
%           nonempty, the hint will be expanded to also include all FEs
%           that share any vertex with the hint FEs.
%
%   'mindist'   If supplied, a positive number.  No element whose
%           coordinates all lie further than this distance from p in any
%           direction will be considered.  If all elements fail this test
%           then ci is returned as zero, bc as [0 0 0], and bcerr and abserr
%           as Inf.  This should be considered an error.  A suitable value might be
%           the diameter of the mesh divided by the square root of the number of
%           FEs, or some fraction of that.
%
%   'tolerance'   If supplied, a positive number.  The search will be
%           terminated as soon as an element is found for which abserr is
%           below this value. If there is no such element, then the element
%           that minimises abserr is returned, the same as when tolerance is
%           not specified.
%
%   These results are returned:
%
%   ci: The index of the FE.
%   bc: The barycentric coodinates of p in that FE, normalised to force it
%       to lie in the FE (i.e. no negative components).
%   bcerr: The magnitude of the most negative component of bc before
%          normalisation.
%   d: The distance between p and the point found.
%   
%   ishint is true if ci is one of the hint cells.
%
%   p1: The closest point to p in the triangle.
%
%   If the mesh and the point p are in the XY plane, then whenever all
%   components of bc are positive, abserr will be within rounding error of
%   zero.  This is not the case in three dimensions, as p may not lie in
%   the plane of the finite element it is closest to lying in.

    ci = 0;
    bc = [0 0 0];
    bcerr = Inf;
    d = Inf;
    ishint = false;
    p1 = [];

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'hint', [], 'only', false, 'expand', false, 'mindist', [], 'tolerance', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'hint', 'only', 'expand', 'mindist', 'tolerance' );
    if ~ok, return; end

    if isempty(s.hint)
        s.only = false;
        s.expand = false;
    else
        s.hint = reshape(s.hint,1,[]);
    end
    
    if s.expand
        s.hint = [ s.hint, feVxNbs( m, s.hint ) ];
    end

    if s.only
        cells = s.hint;
    else
        othercells = true(1,size(tris,1));
        othercells(s.hint) = false;
        cells = [ s.hint find(othercells) ];
    end
    
    numcells = length(cells);
    
    if ~isempty(s.mindist)
        lowx = vxs(:,1)-p(1) < -s.mindist;
        lowy = vxs(:,2)-p(2) < -s.mindist;
        lowz = vxs(:,3)-p(3) < -s.mindist;
        hix = vxs(:,1)-p(1) > s.mindist;
        hiy = vxs(:,2)-p(2) > s.mindist;
        hiz = vxs(:,3)-p(3) > s.mindist;

        tcv = reshape( tris(cells,:)', [], 1 );
        farcells = all( reshape( lowx( tcv ), 3, [] ), 1 ) ...
                   | all( reshape( lowy( tcv ), 3, [] ), 1 ) ...
                   | all( reshape( lowz( tcv ), 3, [] ), 1 ) ...
                   | all( reshape( hix( tcv ), 3, [] ), 1 ) ...
                   | all( reshape( hiy( tcv ), 3, [] ), 1 ) ...
                   | all( reshape( hiz( tcv ), 3, [] ), 1 );
    else
        farcells = false(1,numcells);
    end
    
    numfar = 0;
    for i=find(~farcells)
        ci1 = cells(i);
        fecoords = vxs(tris(ci1,:),:);
        far = bbfar( fecoords, p, d );
        if far
            numfar = numfar+1;
        else
            [p1,bcs1,d1,nbcs1] = pointToTriangle3D( fecoords, p );
            if d1 < d
                ishint = i <= length(s.hint);
                ci = ci1;
                bc = bcs1;
                bcerr = min( 0, min(nbcs1) );

                d = d1;
                if ~isempty(s.tolerance) && (d < s.tolerance)
                    break;
                end
            end
        end
    end
    % fprintf( 1, '%s: far = %d/%d = %f\n', mfilename(), numfar, numcells, numfar/numcells );
end

function far = quicktest( fecoords, p, d )
% Test whether p lies outside the bounding box of fecoords by a distance of
% at least d.
    if isinf(d)
        far = false;
        return;
    end
    dx = fecoords(:,1)-p(1);
    if all(dx <= -d) || all(dx >= d)
        far = true;
        return;
    end
    dy = fecoords(:,2)-p(2);
    if all(dy <= -d) || all(dy >= d)
        far = true;
        return;
    end
    dz = fecoords(:,3)-p(3);
    if all(dz <= -d) || all(dz >= d)
        far = true;
        return;
    end
    far = false;
end
