function [ ci, bc, bcerr, d, ishint, p1 ] = findTetrahedron( vxs, tetras, p, varargin )
%[ ci, bc, bcerr, abserr, ishint, p1 ] = findTetrahedron( vxs, tetras, p, ... )
%   Find which tetrahedron the point P is closest to lying in.
%
%   The following named options may also be given.
%
%   'hint'  A list of FEs to try first.  As currently implemented, this
%           option (and the 'expand' option) has no effect unless 'only' is
%           also true.
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
%           then ci is returned as zero, bc as [0 0 0], and bcerr and d
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
%   d:  The distance between p and the point found.
%   
%   ishint is true if ci is one of the hint cells.
%
%   p1 is the closest point to p in the selected tetrahedron.

    % Initialise all of the output arguments.
    ci = 0;
    bc = [0 0 0];
    bcerr = Inf;
    d = Inf;
    ishint = false;
    p1 = [];
    
    % Process the options.
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'hint', [], 'only', false, 'expand', false, 'mindist', [], 'tolerance', 0 );
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
        othercells = true(1,size(tetras,1));
        othercells(s.hint) = false;
        cells = [ s.hint find(othercells) ];
    end
    
    dims = 3;
    vxsperFE = 4;
    numvxs = size(vxs,1);
    numcells = length(cells);
    
    % Calculate distance of p from the bounding box of each tetrahedron.
    % Then sort the tetrahedra by this distance.  They will be tested in
    % that order.
    vxsp = vxs - repmat( p, numvxs, 1 );
    vxspertetra = reshape( vxsp(tetras(cells,:)',:), vxsperFE, numcells, dims );
    maxtetra = shiftdim( max( vxspertetra, [], 1 ) );
    mintetra = shiftdim( min( vxspertetra, [], 1 ) );
    max1tetra = min(maxtetra,[],2);
    min1tetra = max(mintetra,[],2);
    bbdistance = max( min1tetra, -max1tetra );
    [sortedbbdistance,perm] = sort( bbdistance );
    maxPoorAttempts = min( 20, length(perm) );
    numPoorAttempts = 0;
    
    
    for i=1:length(perm)
        if sortedbbdistance(i) >= d
            % The point cannot be closer to this or any later tetrahedron
            % than any previous one, therefore we can stop.  Typically
            % less than a dozen tetrahedra are examined before this
            % happens.
            break;
        end
        pi = perm(i);
        ci1 = cells(pi);
        fecoords = vxs(tetras(ci1,:),:);
        if any(isnan(fecoords(:)))
            continue;
        end
        [p1a,bc1,d1,bcraw] = pointToTetrahedron( fecoords, p );
        if d1 < d
            % The point is closer to this tetrahedron than any previous
            % one.  Save the current results.
            ci = ci1;
            bc = bc1;
            bcerr = max( -min(bcraw), max(bcraw-1) );
            d = d1;
            p1 = p1a;
%             checkp = bcrawz*fecoords;
%             checkp1 = bcrawz*fecoords - p1z;
            if d <= s.tolerance
                % The current tetrahedron contains the point (or is near
                % enough to it), therefore is optimal.
                break;
            end
        end
        
        if sortedbbdistance(i) > 0
            numPoorAttempts = numPoorAttempts+1;
            if numPoorAttempts >= maxPoorAttempts
                break;
            end
        end
    end
    
    if d > 1e-3
        xxxx = 1;
    end
    
    ishint = ~isempty(s.hint) && ~isempty(find(s.hint==ci,1));
end


