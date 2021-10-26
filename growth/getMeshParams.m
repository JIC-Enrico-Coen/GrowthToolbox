function [mp,ok] = getMeshParams( h )
%mp = getMeshParams( h )
%   Get the currently selected mesh type and read all of its parameters
%   from the GUI.

    global MESH_PARAMS
    meshTypeHandle = h.generatetype;
    meshTypes = get( meshTypeHandle, 'String' );
    meshType = lower( meshTypes{ get(meshTypeHandle, 'Value') } );
    meshType = regexprep( meshType, '[^a-z0-9]', '' );
    ok = true;
    mp = struct();
    if ~isfield( MESH_PARAMS, meshType )
        % Oops.
        ok = false;
    else
        mpspec = MESH_PARAMS.(meshType);
        if isfield( mpspec, 'otherparams' )
            mp.otherparams = mpspec.otherparams;
            mpspec = rmfield( mpspec, 'otherparams' );
        end
        fns = fieldnames(mpspec);
        for i=1:length(fns)
            fn = fns{i};
            paramspec = mpspec.(fn);
            if isstruct(paramspec)
                tag = sprintf( 'geomparam%d%d', paramspec.row, paramspec.col );
                if isfield( h, tag )
                    [val,ok1] = getDoubleFromDialog( h.(tag) );
                    if ~ok1
                        val = paramspec.default;
                    end
                    mp.(fn) = val;
                else
                    mp.(fn) = paramspec.default;
                end
            end
        end
        if isfield( mpspec, 'constructor' )
            mp.constructor = mpspec.constructor;
        else
            mp.constructor = lower( mpspec.menuname );
        end
        [x,ok1] = getDoubleFromDialog( h.thicknessText, 0 );
        if ok1 && (x > 0)
            mp.thickness = x;
        else
            mp.thickness = 0;
        end
    end
end
