function labelAxes( ax, x, y, z )
    xlabel = 'X';
    ylabel = 'Y';
    zlabel = 'Z';
    if nargin < 1
        theaxes = gca;
    elseif ischar(ax) || isempty(ax)
        theaxes = gca;
        if nargin >= 1
            xlabel = x;
        end
        if nargin >= 2
            ylabel = y;
        end
        if nargin >= 3
            zlabel = z;
        end
    else
        theaxes = ax;
        if nargin >= 2
            xlabel = x;
        end
        if nargin >= 3
            ylabel = y;
        end
        if nargin >= 4
            zlabel = z;
        end
    end
    set( get( theaxes, 'XLabel' ), 'String', xlabel );
    set( get( theaxes, 'YLabel' ), 'String', ylabel );
    set( get( theaxes, 'ZLabel' ), 'String', zlabel );
end
