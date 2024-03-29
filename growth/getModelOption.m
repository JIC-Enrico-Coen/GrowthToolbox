function [v,vs] = getModelOption( m, optionname )
%[v,vs] = getModelOption( m, optionname )
%   Get a single model option from the GFtbox model M.  V is the value of
%   that option. VS is the set of all allowed values for that option, or []
%   if all values are allowed.
%
%   If the option does not exist, V and VS are returned as empty. Note that
%   this is not distinguishable from the case where V exists and is empty,
%   and the set of allowed values is empty.

    if isfield( m, 'modeloptions' )
        options = m.modeloptions;
    else
        options = m.userdata.ranges;
    end
    [v,vs] = getOption( options, optionname );
end
