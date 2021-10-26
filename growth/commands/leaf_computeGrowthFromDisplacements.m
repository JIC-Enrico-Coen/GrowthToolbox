function [out1, out2, out3, out4] = leaf_computeGrowthFromDisplacements( m, displacements, timeinterval, varargin )
%[out1, out2, out3, out4] = leaf_computeGrowthFromDisplacements( m, displacements, time, ... )
%   Compute the growth rate in each FE of m given the displacements of all
%   the prism nodes and the time over which these displacements happened.
%   This assumes that m is in the state after these
%   displacements have happened.  The results returned depend on the
%   options and on how many output arguments are given.  Note that unlike
%   most leaf_* commands, m itself is not one of the output arguments,
%   since this procedure does not need to modify m.
%
%   The growth rates are returned as an N*3 matrix with one row for each
%   finite element.  The ordering of the three values is determined by the
%   'axisorder' option.
%
%   If the displacement array is empty or the time interval is not
%   positive, then zeros will be returned.
%
%   Options:
%
%   'frames': a boolean.  If true, then the frames of reference defining the
%   directions of growth will also be returned, as a 3*3*N matrix.  The
%   axes of each 3*3 matrix are its columns.  Their ordering is the same as
%   the ordering of growth rates.  frames need only be specified when two
%   output arguments are given, since it is then required to disambiguate
%   which two output values the caller wants.
%
%   'axisorder': a string, one of 'parpernor' (the default), 'maxminnor',
%   or 'descending'. This determines the ordering of the growth rates and
%   axes at each point.  'parpernor' returns them in the order parallel to
%   the polariser gradient, perpendicular to it within the surface, and normal
%   to the surface.  (To be precise, the "parallel" axis is the tensor axis
%   that is closest to being parallel to the gradient, "perpendicular" is
%   the closest to the perpendicular direction, and "normal" is orthogonal
%   to the other two.) 'maxminnor' also puts the rate normal to the surface
%   last, but of the first two it puts the largest value first.
%   'descending' puts all three values in descending order.
%
%   'anisotropythreshold': a non-negative number.  Wherever the anisotropy
%   is less than this value, the growth rates returned will be set to zero.
%   Anisotropy is measured in terms of kmax (maximum in-surface growth
%   rate) and kmin (minimum in-surface growth rate) by the following
%   formula: (kmax-kmin)/kmax, or zero if kmax is zero.  Anisotropy is zero
%   when growth is perfectly isotropic, and 1 where growth is in one
%   direction only.  Pass a value of zero (the default) to allow all values
%   of anisotropy.
%
%   'exponential': The value of this option is a non-negative real number.
%   If zero (the default) the growth rate reported will be the amount of
%   growth divided by the time interval TO BE COMPLETED
%
%   If one output argument is given, then the result
%   will be the requested growth rates for each finite element.
%
%   If frames is true (the default) and two output arguments are given,
%   then the first result will be the requested growth rates for each
%   finite element, and the second will be the frames of reference.
%
%   If frames is false and two output arguments are given, then the first
%   result will be the growth rates for the A side of each finite
%   element, and the second result will be the rates for the B side.
%
%   If four output arguments are given, then the first
%   result will be the requested growth rates on the A side for each finite
%   element, the second will be the corresponding frames of reference, and
%   the third and fourth will be the growth rates and frames of reference
%   for the B side.
%
%   For example, to plot the parallel growth rate for a given set of
%   displacements from within the interaction function, one can write:
%
%     growth = leaf_computeGrowthFromDisplacements( m, displacements );
%     m = leaf_plotoptions( m, ...
%           'perelement', growth(:,1), 'cmaptype', 'monochrome' );
%
%   To use this to plot the growth that has taken place over some extended
%   time interval, you should at the beginning of that interval store the
%   current locations of all of the vertexes, e.g. like this:
%
%   if (we are at the start of the interval)
%       m.userdata.oldpositions = m.prismnodes;
%       m.userdata.starttime = m.globalDynamicProps.currenttime;
%   end
%
%   When it is time to calculate the growth, the growth rate parallel to
%   the polariser gradient can be calculated and plotted thus:
%
%   if (we are at the end of the interval)
%       displacements = m.prismnodes - m.userdata.oldpositions;
%       growth = leaf_computeGrowthFromDisplacements( m, displacements, ...
%                   m.globalDynamicProps.currenttime - m.userdata.starttime );
%       m = leaf_plotoptions( m, ...
%             'perelement', growth(:,1), 'cmaptype', 'monochrome' );
%   end
%
%   For areal growth rate you would use growth(:,1)+growth(:,2).
%
%   CAUTIONS:
%
%   1.  The above method of calculating growth over an interval requires
%   that no subdivision or transformation of the mesh have taken place
%   during that interval, otherwise m.prismnodes and
%   m.userdata.oldpositions may have different sizes.
%
%   2.  The interaction function is called before growth is computed,
%   so the values plotted as a result of the above code will be one step
%   out of date.  You can plot the up-to-date values by clicking the "Call"
%   button in GFtbox in order to just call the interaction function without
%   performing a growth step, but for this to be safe you must write your
%   interaction function in such a way that calling it twice in a row
%   always has the same effect as calling it once.

    out1 = [];
    out2 = [];
    out3 = [];
    out4 = [];
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok
        return;
    end
    % outputaxes: major, minor, par, perp, areal, total
    if nargout < 2
        s.frames = false;
    elseif nargout > 2
        s.frames = true;
    else
        s = defaultfields( s, ...
                'frames', true, ...
                'axisorder', 'parpernor', ...
                'anisotropythreshold', 0, ...
                'exponential', 2 );
    end
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'frames', 'axisorder', 'anisotropythreshold', 'exponential' );
    if ~ok, return; end
    
    numcells = size(m.tricellvxs,1);

    if isempty(displacements) || (timeinterval <= 0)
        if nargout < 2
            out1 = zeros( numcells, 3 );
        elseif nargout > 2
            out1 = zeros( numcells, 3 );
            out2 = repmat( eye(3), [1, 1, numcells] );
            out3 = zeros( numcells, 3 );
            out4 = repmat( eye(3), [1, 1, numcells] );
        elseif s.frames
            out1 = zeros( numcells, 3 );
            out2 = repmat( eye(3), [1, 1, numcells] );
        else
            out1 = zeros( numcells, 3 );
            out2 = zeros( numcells, 3 );
        end
        return;
    end

    dsA = zeros(6,numcells);
    dsB = zeros(6,numcells);
    for ci=1:numcells
        trivxs = m.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        [dsA(:,ci),dsB(:,ci)] = computeDispStrains( ...
            m.celldata(ci).gnGlobal, displacements(prismvxs,:) );
    end
    if strcmp( s.axisorder, 'descending' )
        preferredFrames = [];
        preferredFramesA = [];
        preferredFramesB = [];
    elseif isempty( m.cellFramesB )
        preferredFrames = m.cellFrames;
        preferredFramesA = preferredFrames;
        preferredFramesB = preferredFramesA;
    else
        preferredFrames = m.cellFrames;
        preferredFramesA = m.cellFramesA;
        preferredFramesB = m.cellFramesB;
    end
    maxmin = strcmp( s.axisorder, 'maxminnor' );
    g1 = [];
    gf1 = [];
    g2 = [];
    gf2 = [];
    if nargout < 2
        g1 = tensorsToComponents( ((dsA+dsB)/2)', preferredFrames, maxmin );
        g1 = growthToGrowthRate( g1, timeinterval, s.exponential );
    elseif nargout > 2
        [g1,gf1] = tensorsToComponents( dsA', preferredFramesA, maxmin );
        [g2,gf2] = tensorsToComponents( dsB', preferredFramesB, maxmin );
        g1 = growthToGrowthRate( g1, timeinterval, s.exponential );
        g2 = growthToGrowthRate( g2, timeinterval, s.exponential );
    elseif s.frames
        [g1,gf1] = tensorsToComponents( ((dsA+dsB)/2)', preferredFrames, maxmin );
        g1 = growthToGrowthRate( g1, timeinterval, s.exponential );
    else
        g1 = tensorsToComponents( dsA', preferredFramesA, maxmin );
        g2 = tensorsToComponents( dsB', preferredFramesB, maxmin );
        g1 = growthToGrowthRate( g1, timeinterval, s.exponential );
        g2 = growthToGrowthRate( g2, timeinterval, s.exponential );
    end
    if ~isempty(g1) && ~isempty(gf1)
        aa = sort( g1(:,[1 2]), 2 );
        anisotropies = (aa(:,2) - aa(:,1))./aa(:,2);
        nearisotropic = anisotropies < s.anisotropythreshold;
        if any(nearisotropic)
            xxxx = 1;
        end
        gf1( :, :, nearisotropic ) = 0;
    end
    if ~isempty(g2) && ~isempty(gf2)
        aa = sort( g2(:,[1 2]), 2 );
        anisotropies = (aa(:,2) - aa(:,1))./aa(:,2);
        nearisotropic = anisotropies < s.anisotropythreshold;
        gf2( :, :, nearisotropic ) = 0;
    end
    if nargout < 2
        out1 = g1;
    elseif nargout > 2
        out1 = g1;
        out2 = gf1;
        out3 = g2;
        out4 = gf2;
    elseif s.frames
        out1 = g1;
        out2 = gf1;
    else
        out1 = g1;
        out2 = g2;
    end
end

function growth = growthToGrowthRate( growth, timeinterval, exponential )
    switch exponential
        case 2
            % This version makes perfect sense.
            growth = -(log(1-growth))/timeinterval;
            % It's equivalent to this:
%             growth = 1/(1-growth);
%             growth = log(1+growth)/timeinterval;
            % The first line of that transforms the growth from being
            % relative to the current size, to being relative to the
            % previous size.  Then we use the standard transformation to
            % get an exponential growth rate.
        case false
            growth = growth/timeinterval;
        otherwise
            % Including when exponential is true (the default).
            growth = log(1+growth)/timeinterval;
    end
end

function [dsA,dsB] = computeDispStrains( gnGlobal, displacements )
%[dsA,dsB] = computeDispStrains( gnGlobal, displacements )
%   Set [dsA,dsB] equal to the strain at each Gauss point
%   resulting from the given displacements of the vertexes.

    numGaussPoints = size(gnGlobal,3);
    ds6 = zeros(6,6);
    SMALL_ROTATIONS_ASSUMED = false;
    for i=1:numGaussPoints
        ui = gnGlobal(:,:,i) * displacements;
        e = 0.5*(ui + ui');
        if SMALL_ROTATIONS_ASSUMED
            e = 0.5*(ui + ui');
            if nargout > 0
                vort = 0.5*(ui-ui');
                vorticity(:,:,i) = eye(3) + vort;
            end
        else
            t = eye(3) + ui;
            [q,err] = extractRotation( t );
            e = t*q' - eye(3);
%             olde = 0.5*(ui + ui');
%             oldvort = 0.5*(ui-ui');
            if nargout > 0
                vorticity(:,:,i) = q;
            end
        end
        ds6(:,i) = make6vector( e );
    end
    dsA = sum( ds6(:,1:3), 2 )/3;
    dsB = sum( ds6(:,4:6), 2 )/3;
end
