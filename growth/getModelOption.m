function [v,vs] = getModelOption( m, optionname )
%[v,vs] = getModelOption( m, optionname )
%   Get a single model option.  v is the value of that option. vs is the
%   set of all allowed values for that option, or [] if all values are
%   allowed.
%
%   If the option does not exist, v and vs are returned as empty.

    if isfield( m, 'modeloptions' )
        options = m.modeloptions;
    else
        options = m.userdata.ranges;
    end
    [v,vs] = getOption( options, optionname );
end
