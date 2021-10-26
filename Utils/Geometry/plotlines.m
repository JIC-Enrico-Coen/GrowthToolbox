function h = plotlines( ends, vxs, varargin )
%function h = plotlines( ends, vxs, varargin )
%h = plotlines( ends, vxs, varargin )
%   Plot a set of line segments in the given axes.
%   ENDS is an N*2 array of indexes into VXS, a K*2 or K*3 array of points.
%   The remaining arguments are plotting options common to all the lines,
%   which must all have the same colour, width, line style, etc.

    h = plotIndexedLines( ends, vxs, vxs, varargin{:} );
end
