function h = plotMultipropertyLines( ends, vxs, propertyindex, properties, varargin )
%h = plotMultipropertyLines( ends, vxs, propertyindex, properties, varargin )
%   Plot a set of line segments in the given axes, of varying widths.
%   ENDS is an N*2 array of indexes into VXS, a K*2 or K*3 array of points.
%   PROPERTYINDEX is a vector specifying for each line an index in
%   PROPERTIES, which is a struct array with fields 'LineWidth' and
%   'Color', specifying these plotting properties for every line having the
%   corresponding index.
%   The remaining arguments are plotting options common to all the lines,
%   which must all have the same colour, width, line style, etc.

    h = plotMultipropertyIndexedLines( ends, vxs, vxs, propertyindex, properties, varargin{:} );
end
