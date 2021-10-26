function m = clearModelOptions( m )
%m = clearModelOptions( m )
%   Remove all of the model options.

    if isfield( m, 'modeloptions' )
        m.modeloptions = struct();
    else
        m.userdata.ranges = struct();
    end
end

