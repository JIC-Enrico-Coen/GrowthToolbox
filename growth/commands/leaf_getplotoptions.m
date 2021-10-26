function s = leaf_getplotoptions( m, varargin )
%s = leaf_getplotoptions( m, ... )
%   Read the default plotting options.
%   See LEAF_PLOT for details.
%
%   The arguments are names of any plotting options that can be passed to
%   LEAF_PLOT or LEAF_PLOTOPTIONS.  The result is a structure whose fields
%   are those option names and whose values are the values they have in m.
%   Unrecognised options will be ignored.
%
%   Unlike most leaf_* commands, this command does not modify m and
%   therefore does not return a new value of m.
%
%   See also: leaf_plot, leaf_plotoptions.
%
%   Topics: Plotting.

    s = struct();
    for i=1:length(varargin)
        try
            s.(varargin{i}) = m.plotoptions.(varargin{i});
        catch
            % Ignore missing options.
        end
    end
end


