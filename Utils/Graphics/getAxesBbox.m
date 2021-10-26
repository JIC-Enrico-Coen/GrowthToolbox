function [bbox,centre] = getAxesBbox( ax )
%[bbox,centre] = getAxesBbox( ax )
%   Find the bounding box, and its centre, of all the data that is plotted
%   in the axes object AX.

    bbox = [ Inf Inf Inf; -Inf -Inf -Inf ];
    axc = ax.Children;
    for i=1:length(axc)
        c = axc(i);
        fns = {'XData','YData','ZData'};
        for fni=1:length(fns)
            fn = fns{i};
            try
                % We have to use try/catch, because isfield() does not work
                % on handles.
                v = c.(fn);
                if ~isempty(v)
                    bbox(1,fni) = min( bbox(1,fni), min(v(:)) );
                    bbox(2,fni) = max( bbox(1,fni), max(v(:)) );
                end
            catch
            end
        end
    end
    centre = sum(bbox,1)/2;
end
