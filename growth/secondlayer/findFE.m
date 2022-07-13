function [ ci, bc, bcerr, abserr, ishint, bcs, bcerrs, abserrs ] = findFE( m, p, varargin )
%[ ci, bc, bcerr, abserr, bcs, bcerrs, abserrs ] = findFE( m, p, hint, ... )
%   Find which finite element of the mesh M the point P is closest to lying
%   in.
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
%   abserr: The distance between p and the point found.
%   
%   The remaining results are primarily for debugging.
%
%   ishint is true if ci is one of the hint cells.
%
%   bcs, bcerrs, abserrs: The values of bc, bcerr, and abserr for all FEs
%       tested.  If 'hint' was specified and ONLY was false, the values for
%       the hint FEs are listed first, followed by those for all the other
%       FEs in numerical order.  Some values of bcerrs and abserrs may be
%       Inf.  The corresponding values of bcs will be all zero.  These are
%       cases where the FE was excluded from being the best one by a faster
%       computation that did not need to compute the barycentric
%       coordinates.
%
%   If the mesh and the point p are in the XY plane, then whenever all
%   components of bc are positive, abserr will be within rounding error of
%   zero.  This is not the case in three dimensions, as p may not lie in
%   the plane of the finite element it is closest to lying in.
%
%   When p lies outside the element, the point implied by the normalised
%   barycentric coordinates is in general not the closest point of the
%   element to p. This implies that if p is outside all of the finite
%   elements, the selected element may not be the one that p is closest to.
%   However, the difference is likely to be small.

    bcs = [];
    bcerrs = [];
    abserrs = [];

    numpts = size(p,1);
    isvol = isVolumetricMesh(m);
    if isvol
        bclength = 4;
    else
        bclength = 3;
    end
    if numpts > 1
        ci = zeros(numpts,1);
        bc = zeros(numpts,bclength);
        bcerr = zeros(numpts,1);
        abserr = zeros(numpts,1);
        ishint = zeros(numpts,1);
        if isvol
            for i=1:numpts
                [ ci(i), bc(i,:), bcerr(i), abserr(i), ishint(i), p1 ] = findTetrahedron( m.FEnodes, m.FEsets.fevxs, p(i,:), varargin{:} );
            end
        else
            for i=1:numpts
                [ ci(i), bc(i,:), bcerr(i), abserr(i), ishint(i), p1 ] = findTriangle( m.nodes, m.tricellvxs, m.unitcellnormals, p(i,:), varargin{:} );
            end
        end
    elseif isvol
        [ ci, bc, bcerr, abserr, ishint, p1 ] = findTetrahedron( m.FEnodes, m.FEsets.fevxs, p, varargin{:} );
    else
        [ ci, bc, bcerr, abserr, ishint, p1 ] = findTriangle( m.nodes, m.tricellvxs, m.unitcellnormals, p, varargin{:} );
    end
    return;

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
        othercells = true(1,size(m.tricellvxs,1));
        othercells(s.hint) = false;
        cells = [ s.hint find(othercells) ];
    end
    
    numcells = length(cells);
    bcs = zeros(numcells,3);
    bcerrs = Inf(numcells,1);
    abserrs = Inf(numcells,1);
    
    besti = 0;
    bestbc = [0 0 0];
    bestbcerr = Inf;
    bestabserr = Inf;
    
    if ~isempty(s.mindist)
        lowx = m.nodes(:,1)-p(1) < -s.mindist;
        lowy = m.nodes(:,2)-p(2) < -s.mindist;
        lowz = m.nodes(:,3)-p(3) < -s.mindist;
        hix = m.nodes(:,1)-p(1) > s.mindist;
        hiy = m.nodes(:,2)-p(2) > s.mindist;
        hiz = m.nodes(:,3)-p(3) > s.mindist;

        tcv = reshape( m.tricellvxs(cells,:)', [], 1 );
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
        c = cells(i);
        fecoords = m.nodes(m.tricellvxs(c,:),:);
        far = quicktest( fecoords, p, bestabserr );
        % far = quicktest1( c );
        if far
            numfar = numfar+1;
            bcerrs(i) = Inf;
            abserrs(i) = Inf;
        else
            bc = cellBaryCoords( m, c, p, false );
            bcerrs(i) = min( 0, min(bc) );
            bc = normaliseBaryCoords( bc );
            abserrs(i) = norm(p-bc*fecoords);
            bcs(i,:) = bc;

            if abserrs(i) < bestabserr
                besti = i;
                bestbc = bc;
                bestbcerr = bcerrs(i);
                bestabserr = abserrs(i);
                if ~isempty(s.tolerance) && (bestabserr < s.tolerance)
                    break;
                end
            end
        end
    end
    % fprintf( 1, '%s: far = %d/%d = %f\n', mfilename(), numfar, numcells, numfar/numcells );
    
    abserr = bestabserr;
    ci = cells(besti);
    bc = bestbc;
    bcerr = bestbcerr;
    ishint = besti <= length(s.hint);

function far = quicktest1( ci )
    vis = m.tricellvxs(ci,:);
    far = all(lowx(vis)) | all(lowy(vis)) | all(lowz(vis)) | all(hix(vis)) | all(hiy(vis)) | all(hiz(vis));
end
end

function far = quicktest( fecoords, p, d )
    if isinf(d)
        far = false;
        return;
    end
    dx = fecoords(:,1)-p(1);
    if all(dx < -d) || all(dx > d)
        far = true;
        return;
    end
    dy = fecoords(:,2)-p(2);
    if all(dy < -d) || all(dy > d)
        far = true;
        return;
    end
    dz = fecoords(:,3)-p(3);
    if all(dz < -d) || all(dz > d)
        far = true;
        return;
    end
    far = false;
end
