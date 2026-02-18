function h = hasModelOption( m, optionname )
%h = hasModelOption( m, optionname )
%   Determine whether the given option exists in m.

    if isfield( m, 'modeloptions' )
        options = m.modeloptions;
    else
        options = m.userdata.ranges;
    end
    h = isfield( options, optionname );
end
