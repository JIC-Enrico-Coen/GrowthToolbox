function [v,vs] = getOption( options, optionname )
%[v,vs] = getOption( options, optionname )
%   Get the value of a single option of a GFtbox model.
%
%   OPTIONS is a structure specifying all of the options for a GFtbox
%   model. This is a struct mapping each option name to a structure with
%   fields RANGE, VALUE, and INDEX. RANGE, if nonempty, lists the allowed
%   values for the option. If RANGE is empty, all values are allowed. VALUE
%   is the default value of that option. INDEX is zero if RANGE is empty,
%   otherwise it specifies the index in RANGE where VALUE is found.
%
%   V is the value of the option having the given OPTIONNAME. VS is the
%   set of all allowed values for that option, or [] if all values are
%   allowed.
%
%   If the option does not exist, V and VS are returned as empty. Note that
%   this is not distinguishable from the case where V exists and is empty,
%   and the set of allowed values is empty.

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
