function [v,vs] = getOption( options, optionname )
%[v,vs] = getOption( m, optionname )
%   Get a single option.  v is the value of that option. vs is the
%   set of all allowed values for that option, or [] if all values are
%   allowed.
%
%   If the option does not exist, v and vs are returned as empty.

    if isfield( options, optionname )
        vs = options.(optionname).range;
        if isempty( vs )
            v = options.(optionname).value;
        elseif iscell( vs )
            v = options.(optionname).range{options.(optionname).index};
        else
            v = options.(optionname).range(options.(optionname).index);
        end
    else
        v = [];
        vs = [];
    end
end
