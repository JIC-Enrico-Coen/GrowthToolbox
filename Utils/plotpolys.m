function p = plotpolys( ax, vxs, polys, varargin )
%p = plotpolys( ax, vxs, polys, ... )
%   Plot a set of polygons in the given axes.
%   POLYS can be either an array in which each row lists the vertexes of a
%   polygon (with unused trailing spaces filled by either 0 or NaN), or a
%   cell array in which each element is a list of the vertexes of one
%   polygon (with no padding).
%
%   The remaining arguments are passed to patch().
%
%   This procedure adds the polygons to the axes without deleting whatever
%   is already there.
%
%   The result is a handle to the patch object.

    if iscell(polys)
        numpolys = length(polys);
        maxlen = 0;
        for i=1:numpolys
            maxlen = max( maxlen, length(polys{i}) );
        end
        newpolys = nan(numpolys,maxlen);
        for i=1:numpolys
            n = length(polys{i});
            newpolys(i,1:n) = polys{i};
        end
        polys = newpolys;
    else
        % polys is assumed to be an array in which unused positions are
        % filled with zero or NaN and are in trailing positions in each
        % row.
        numpolys = size(polys,1);
        polys(polys==0) = NaN;
        if ~any(isnan(polys(:,end)))
            polys = [ polys, nan(numpolys,1) ];
        end
    end
    
    p = patch( 'Faces', polys, 'Vertices', vxs, 'Parent', ax, varargin{:} );
end
