function po = upgradePlotoptions( po )
    global gOBSOLETEPLOTOPTIONS gDefaultPlotOptions gOurViewParams
    
    if isfield( po, 'numbering' )
        po.FEnumbering = po.numbering;
    end

    if isfield( po, 'monochrome' )
        if isempty( po.cmaptype )
            po.cmaptype = ...
                boolchar( po.monochrome, 'monochrome', 'rainbow' );
        end
    end
    
    if isfield( po, 'multimorphogen' )
        po.morphogen = po.multimorphogen;
        po.defaultmultiplottissue = po.multimorphogen;
    elseif isfield( po, 'defaultmultiplot' )
        po.defaultmultiplottissue = po.defaultmultiplot;
    end

    if isfield( po, 'autoRange' )
        po.autoColorRange = po.autoRange;
        po = rmfield( po, 'autoRange' );
    end
    
    po = replacefields( po, ...
        'tensorquantity', 'outputquantity', ...
        'tensorproperty', 'outputaxes' );
    
    if isfield( po, 'outputaxes' ) && isnumeric( po.outputaxes )
        % In an earlier version, outputaxes could be a matrix holding the
        % axes to be drawn, but is now limited to being a string naming the
        % set of tensor components.
        po.outputaxes = '';
    end
    
    if ~isfield( po, 'outputquantity' )
        po.outputquantity = 'resultantgrowthrate';
    end
    if ~isempty( po.outputquantity )
        po.outputquantity = regexprep( po.outputquantity, '^actual', 'resultant' );
    end

    po = defaultFromStruct( po, ...
              struct( ...
                'defaultmultiplotcells', gDefaultPlotOptions.defaultmultiplotcells, ...
                'clipmgens', gDefaultPlotOptions.clipmgens, ...
                'doclip', gDefaultPlotOptions.doclip, ...
                'clippingDistance', gDefaultPlotOptions.clippingDistance, ...
                'clippingThickness', gDefaultPlotOptions.clippingThickness, ...
                'clipbymgen', gDefaultPlotOptions.clipbymgen, ...
                'clipmgenthreshold', gDefaultPlotOptions.clipmgenthreshold, ...
                'clipmgenall', gDefaultPlotOptions.clipmgenall ) );

    po1 = defaultFromStruct( po, gDefaultPlotOptions, ...
              { ...
                'defaultmultiplotcells', ...
                'clipmgens', ...
                'doclip', ...
                'clippingDistance', ...
                'clippingThickness', ...
                'clipbymgen', ...
                'clipmgenthreshold', ...
                'clipmgenall' } );
    if ~compareStructs( po, po1 )
        error( 'Bad code revision.' );
    end

    needZoomCentre = false;
    if isfield( po, 'matlabViewParams' )
        po.matlabViewParams = replacefields( ...
            po.matlabViewParams, 'CameraUp', 'CameraUpVector' );
    end
    if ~isfield( po, 'matlabViewParams' ) ...
            || ~isfield( po, 'ourViewParams' )
        if isfield( po, 'matlabViewParams' )
            po.ourViewParams = ...
                ourViewParamsFromCameraParams( po.matlabViewParams );
        elseif isfield( po, 'ourViewParams' )
            po.matlabViewParams = ...
                cameraParamsFromOurViewParams( po.ourViewParams );
        else
            po.ourViewParams = gOurViewParams;
            po.matlabViewParams = ...
                cameraParamsFromOurViewParams( po.ourViewParams );
            needZoomCentre = true;
        end
    end
    needZoomCentre = needZoomCentre ...
                     || (~isfield( po, 'autozoom' )) ...
                     || (~isfield( po, 'autocentre' ));
    po = defaultFromStruct( po, gDefaultPlotOptions );
    if needZoomCentre
        po.matlabViewParams = ...
            autozoomcentre( po.matlabViewParams, ...
                            po.axisRange, ...
                            true, true );
        po.ourViewParams = ...
            ourViewParamsFromCameraParams( po.matlabViewParams );
    end
    if isfield( po, 'clippingDirection' )
        [ po.clippingAzimuth, po.clippingElevation ] = ...
            dir2azel( po.clippingDirection );
        po = rmfield( po, 'clippingDirection' );
    end
    if isfield( po, 'asidecells' )
        po.decorateAside = ~po.asidecells;
        po = rmfield( po, 'asidecells' );
    end
    if isfield( po, 'secondlayervalue' )
        po.cellbodyvalue = po.secondlayervalue;
        po = rmfield( po, 'secondlayervalue' );
    end
    

    po = safermfield( po, gOBSOLETEPLOTOPTIONS );
end
