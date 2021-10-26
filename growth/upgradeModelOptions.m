function [m,upgraded] = upgradeModelOptions( m )
    upgraded = false;
    if isfield( m, 'modeloptions' )
        return;
    end
    if ~isfield( m.userdata, 'ranges' )
        return;
    end
    m.modeloptions = m.userdata.ranges;
    m.userdata = rmfield( m.userdata, 'ranges' );
end
