function s = newemptystreamline()
%     severance = struct( ...
%         'eventelement', [], ...
%         'eventbcs', [], ...
%         'eventtime', [], ...
%         'eventtype', [] );
    s = struct( ...
            'id', 0, ...
            'vxcellindex', zeros(1,0,'int32'), ...
            'segcellindex', zeros(1,0,'int32'), ...
            'barycoords', zeros(0,3), ...
            'globalcoords', zeros(0,3), ...
            'segmentlengths', zeros(1,0), ...
            'iscrossovervx', false(1,0), ...
            'downstream', true, ...
            'morphogen', '', ...
            'starttime', 0, ...
            'endtime', 0, ...
            'directionbc', zeros(1,3), ...
            'directionglobal', zeros(1,3), ...
            'linecolorindex', 1, ...
            'status', struct( 'head', 1, ...
                              'shrinktail', true, ...
                              'catshrinktail', false, ...
                              'shrinktime', 0, ...
                              'interactiontime', 0, ...
                              'pauseuntil', -Inf, ...
                              'severance', [] ) ...
        );
end