function [bbox,centre] = getAxesDataBbox( ax )
%[bbox,centre] = getAxesDataBbox( ax )
%   Find the bounding box, and its centre, of all the data that is plotted
%   in the axes object AX.

    bbox = [ Inf Inf Inf; -Inf -Inf -Inf ];
    axc = ax.Children;
    for i=1:length(axc)
        c = axc(i);
        fns = {'XData','YData','ZData'};
        for fni=1:length(fns)
            fn = fns{fni};
            try
                % We have to use try/catch, because isfield() does not work
                % on handles.
                v = c.(fn);
                if ~isempty(v)
                    bbox(1,fni) = min( bbox(1,fni), min(v(:)) );
                    bbox(2,fni) = max( bbox(2,fni), max(v(:)) );
                end
            catch
            end
        end
        try
            v = c.Vertices;
            bbox = unionbbox( bbox, [ min(v,[],1); max(v,[],1) ] );
        catch
        end
    end
    centre = sum(bbox,1)/2;
end
