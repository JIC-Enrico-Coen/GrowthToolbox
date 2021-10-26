function [colors,colorinfo] = translateValuesToColors( values, colorinfo )
%[colors,colorinfo] = translateValuesToColors( values, colorinfo )
%   Translate the values to colors according to the parameters in the
%   colorinfo structure. This structure may be changed, and the updated
%   structure is also returned.

    colorinfo = calcColorinfoMap( [min(values) max(values)], colorinfo );
    colors = translateToColors( values, colorinfo.range, colorinfo.colors );
end
