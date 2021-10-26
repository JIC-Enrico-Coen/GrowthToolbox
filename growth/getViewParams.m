function [haveOurViewParams,ourViewParams,haveMatlabViewParams,matlabViewParams,s] = ...
    getViewParams( s )
%[ourViewParams,matlabViewParams,s] = getViewParams( s )

    global gOurViewParams gMatlabViewParams

    haveOurViewParams = false;
    ourViewParams = struct();
    haveMatlabViewParams = false;
    matlabViewParams = struct();
    
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        if isfield( gOurViewParams, fn ) && ~isempty( s.(fn) )
            haveOurViewParams = true;
            ourViewParams.(fn) = s.(fn);
        elseif isfield( gOurViewParams, fn ) && ~isempty( s.(fn) )
            haveMatlabViewParams = true;
            matlabViewParams.(fn) = s.(fn);
        end
    end
    if isfield( s, 'ourViewParams' ) && ~isempty( s.ourViewParams )
        haveOurViewParams = true;
        ourViewParams = defaultFromStruct( ourViewParams, s.ourViewParams );
        s = rmfield( s, 'ourViewParams' );
    end
    if isfield( s, 'matlabViewParams' ) && ~isempty( s.matlabViewParams )
        haveMatlabViewParams = true;
        matlabViewParams = defaultFromStruct( matlabViewParams, s.matlabViewParams );
        s = rmfield( s, 'matlabViewParams' );
    end
end
