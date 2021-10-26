function s = addTubuleSeverancePoint( s, vx, t )
%s = addTubuleSeverancePoint( s, vx, t )
%   Add a severance point to the microtubule s.
%   vx is the index of a vertex where it is to be severed.
%   t is the absolute time at which it should be severed (if it still
%   exists).

    severance = struct( ...
            'time', t, ...
            'vertex', vx, ...
            'FE', s.vxcellindex(vx), ...
            'bc', s.barycoords(vx,:), ...
            'globalpos', s.globalcoords(vx,:) );
    if isempty( s.severance )
        s.severance = severance;
    else
        s.severance(end+1) = severance;
    end
end
