function s = leaf_getproperty( m, varargin )
%s = leaf_getproperty( m, ... )
%   Read various properties of the mesh.
%
%   The arguments are any property names that can be passed to
%   leaf_setproperty.  The result is a structure whose fields
%   are those names and whose values are the values they have in m.
%   Unrecognised names will be ignored.
%
%   Unlike most leaf_* commands, this command does not modify m and
%   therefore does not return a new value of m.
%
%   See also: leaf_setproperty.
%
%   Topics: Misc.

    s = struct();
    for i=1:length(varargin)
        try
            s.(varargin{i}) = m.globalProps.(varargin{i});
        catch
            try
                s.(varargin{i}) = m.globalDynamicProps.(varargin{i});
            catch
                % Ignore missing options.
            end
        end
    end
end


