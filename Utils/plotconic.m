function h = plotconic( ax, z, r, steps, varargin )
%h = plotconic( ax, x, r, steps )
%   Plot a lathed surface or generalised cone.
%   AX is the axes object into which to plot.
%   Z and R are vectors of equal length.
%   STEPS is an integer.
%   The surface is plotted, circularly symmetric about the z axis, for
%   which the radius at each point of Z is R.  STEPS is the number of steps
%   to take around the z axis in sweeping out the surface.  The remaining
%   arguments are passed to SURF.
%
%   The surface will be coloured according to the z coordinate.
%
%   See also: SURF.

    z = repmat( z(:), 1, steps+1 );
    r = repmat( r(:), 1, steps+1 );
    theta = (0:steps)*(2*pi/steps);
    rc = r.*repmat( cos(theta), size(r,1), 1 );
    rs = r.*repmat( sin(theta), size(r,1), 1 );
    h = surf( ax, rc, rs, z, z, varargin{:} );
end
