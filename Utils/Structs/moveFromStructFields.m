function [s,t] = moveFromStructFields( t, varargin )
%[s,t] = moveFromStructFields( t, varargin )
%   The variable arguments must be field names of t.
%   Set s to a structure containing those fields of t, and delete them from
%   t.

    for i=1:length(varargin)
        s.(varargin{i}) = t.(varargin{i});
    end
    t = rmfield( t, {varargin{:}} );
end
