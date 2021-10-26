function ax = figureaxes( fig, legends )
%ax = figureaxes( fig, legends )
%   FIG is a figure handle.  Return a list of all the children of FIG that
%   are axes handles.  If LEGENDS is true (the default is false) then
%   legend axes will be included.

    if nargin < 2
        legends = false;
    end
    ax = [];
    if ishandle(fig)
        c = get( fig, 'Children' );
        for i=1:length(c)
            if strcmp( get(c(i),'Type'), 'axes' ) && ...
                    (legends || ~strcmp( get(c(i),'Tag'), 'legend' ))
                ax(length(ax)+1) = c(i);
            end
        end
    end
end
