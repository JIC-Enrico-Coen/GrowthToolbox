function h = plotMultipropertyIndexedLines( edges, v1, v2, propertyindex, properties, varargin )
%h = plotMultipropertyIndexedLines( edges, v1, v2, propertyindex, properties, ... )
%   EDGES is an N*2 array.
%   V1 is an A*3 array
%   V2 is a B*3 array.
%	The first column of EDGES indexes rows of V1, and the second column
%	rows of V2.  Line segments will be drawn joining these points.
%   The result is a single line handle.
%   The remaining arguments after v2 specify plotting options which are the
%   same for all the lines to be plotted.  For the use of PROPERTYINDEX and
%   PROPERTIES, see plotMultipropertyLines.

    h = [];
    if length(varargin)==1
        options = varargin{1};
    else
        options = struct(varargin{:});
    end
    
    if isempty(properties)
        % No properties.  Use the options given.
        h = plotIndexedLines( edges, v1, v2, options );
        return;
    end
    
    propertyindex = min( propertyindex, length(properties) );
    for i=1:length(properties)
        whichlines = propertyindex==i;
        if any(whichlines)
            options.LineWidth = properties(i).LineWidth;
            options.Color = properties(i).Color;
            h = plotIndexedLines( edges(whichlines,:), v1, v2, options );
        end
    end
    
    
%     % Multiple properties.  For each set of properties, plot all the lines
%     % having those properties.
%     numlines = size( edges, 1 );
%     xx = [v1(edges(:,1),1)'; v2(edges(:,2),1)'; nan(1,numlines)];
%     yy = [v1(edges(:,1),2)'; v2(edges(:,2),2)'; nan(1,numlines)];
%     
%     [uw,~,wmap] = unique(widths);
%     MAXLINES = 20;
%     if length(uw) > MAXLINES
%         
%     end
%     
%     if size(v1,2) ~= 2
%         zz = [v1(edges(:,1),3)'; v2(edges(:,2),3)'; nan(1,numlines)];
%     end
%     if isfield( options, 'Color' )
%         colors = options.Color;
%     end
%     for i=1:length(uw)
%         if ~isempty(colors)
%             options.Color = colors(min(length(uw)+1-i,size(colors,1)),:);
%         end
%         subset = wmap==i;
%         if size(v1,2)==2
%             h = line( xx(:,subset), ...
%                   yy(:,subset), ...
%                   'LineWidth', uw(i), ...
%                   options );
%         else
%             h = line( xx(:,subset), ...
%                   yy(:,subset), ...
%                   zz(:,subset), ...
%                   'LineWidth', uw(i), ...
%                   options );
%         end
%     end
end
