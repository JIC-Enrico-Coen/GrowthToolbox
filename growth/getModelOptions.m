function [s,alloptions] = getModelOptions( m, optionnames )
%s = getModelOptions( m )
%s = getModelOptions( m, optionnames )
%   Get the current model options and return them in a struct.
%   The second result is a struct specifying for each option the set of its
%   allowed values, or [] if all values are allowed.
%
%   If optionnames is specified, it should be a cell array of strings, and
%   only options with those names will be returned. Elements of optionnames
%   that are not names of options are ignored.

    s = struct();
    alloptions = struct();
    if isfield( m, 'modeloptions' )
        if isempty( m.modeloptions )
            fns = {};
        else
            fns = fieldnames( m.modeloptions );
        end
    else
        if isempty( m.userdata.ranges )
            fns = {};
        else
            fns = fieldnames( m.userdata.ranges );
        end
    end
    if nargin >= 2
        fns = intersect( fns, optionnames );
    end
    for i=1:length(fns)
        fn = fns{i};
        [s.(fn),alloptions.(fn)] = getModelOption( m, fn );
    end
end
