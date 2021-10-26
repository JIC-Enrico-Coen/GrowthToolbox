function s = upgradeStaticData( s, m )
%s = upgradeStaticData( s, m )
%   Upgrade any old version of static data to the current version.
%   m, if present, is assumed to be already upgraded to the current
%   GFtbox version.  Missing components of s should be defaulted from m,
%   and failing that, from gGlobalProps and gDefaultPlotOptions.

    setGlobals();
    global gGlobalProps gDefaultPlotOptions gDYNAMICFIELDS
    global gOBSOLETEFIELDS gOBSOLETESTATICPROPS gOBSOLETEPLOTOPTIONS
    global gDEFAULTFIELDS gSecondLayerColorInfo

    if nargin < 2
        m = [];
    end
    
    s = safermfield( s, gDYNAMICFIELDS );
    s = safermfield( s, gOBSOLETEFIELDS );
    
    if ~isempty(m)
        if ~isfield( s.globalProps, 'starttime' )
            s.globalProps.starttime = m.globalProps.starttime;
        end
        if ~isfield( s.globalProps, 'validitytime' )
            s.globalProps.validitytime = m.globalProps.validitytime;
        end
    end
    if isfield( s.globalProps, 'usepolfreezebc' ) && ischar( s.globalProps.usepolfreezebc )
         s.globalProps.usepolfreezebc = gGlobalProps.usepolfreezebc;
    end
    if isfield( s.globalProps, 'freezing' )
         s.globalProps = rmfield( s.globalProps, 'freezing' );
    end
    if ~isfield( s.globalProps, 'newcallbacks' )
        % Old-style callbacks cannot be automatically upgraded to
        % new-style, so if this field is missing, it has to be set to
        % false to enable old-style behaviour. New projects set it to true.
        s.globalProps.newcallbacks = false;
    end


    s.globalProps = defaultFromStruct( s.globalProps, gGlobalProps );
    s.globalProps = safermfield( s.globalProps, gOBSOLETESTATICPROPS );
    s.plotdefaults = defaultFromStruct( s.plotdefaults, gDefaultPlotOptions );
    if isfield( s.plotdefaults, 'multimorphogen' )
        s.plotdefaults.morphogen = s.plotdefaults.multimorphogen;
        s.plotdefaults.defaultmultiplottissue = s.plotdefaults.multimorphogen;
    elseif isfield( s.plotdefaults, 'defaultmultiplot' )
        s.plotdefaults.defaultmultiplottissue = s.plotdefaults.defaultmultiplot;
    end

    s.plotdefaults.matlabViewParams = replacefields( ...
        m.plotdefaults.matlabViewParams, 'CameraUp', 'CameraUpVector' );
    s.globalProps.defaultViewParams = replacefields( ...
        m.globalProps.defaultViewParams, 'CameraUp', 'CameraUpVector' );

    s.plotdefaults = safermfield( s.plotdefaults, gOBSOLETEPLOTOPTIONS );

    if ~isempty( s.plotdefaults.outputquantity )
        s.plotdefaults.outputquantity = regexprep( s.plotdefaults.outputquantity, '^actual', 'resultant' );
    end
    
    % Code that follows is duplicated from upgrademesh.  This is bad.
    if ~isfield( s, 'outputcolors' )
        s.outputcolors = struct();
    end
    ocfns = fieldnames( s.outputcolors );
    for i=1:length(ocfns)
        if ~isempty( regexp( ocfns{i}, '^actual' , 'once' ) )
            newocfn = regexprep( ocfns{i}, '^actual', 'resultant' );
            s.outputcolors.(newocfn) = s.outputcolors.(ocfns{i});
            s.outputcolors = rmfield( s.outputcolors, ocfns{i} );
        end
    end
    s.outputcolors = defaultFromStruct( s.outputcolors, gDEFAULTFIELDS.outputcolors );

    if isfield( s, 'mgencolors' )
        s.mgenposcolors = s.mgencolors;
        s = rmfield( s, 'mgencolors' );
    end
    if ~isfield( s, 'mgenposcolors' )
        numMorphogens = size(s.morphogens,2);
        s.mgenposcolors = HSVtoRGB( [ (0:1:(numMorphogens-1))'/12, ones( numMorphogens, 2 ) ] )';
    end
    if ~isfield( s, 'mgennegcolors' )
        s.mgennegcolors = oppositeColor( s.mgenposcolors' )';
    end

    if isfield( s, 'mgen_interpType' ) && ~iscell( s.mgen_interpType )
        numMorphogens = length(s.mgen_interpType);
        newInterpType = cell(1,numMorphogens);
        for i=1:numMorphogens
            switch s.mgen_interpType(i)
                case 2
                    newInterpType{i} = 'min';
                case 3
                    newInterpType{i} = 'max';
                otherwise
                    newInterpType{i} = 'mid';
            end
        end
        s.mgen_interpType = newInterpType;
    end
    
    numMorphogens = length( s.mgen_dilution );
    if (~isfield( s, 'mgen_transportable' )) || (length(s.mgen_transportable) ~= numMorphogens)
        s.mgen_transportable = false( 1, numMorphogens );
    end
    
    if isfield( s, 'secondlayer' )
        if isfield( s.secondlayer, 'cellcolorinfo' )
            s.secondlayer.cellcolorinfo = renameStructFields( s.secondlayer.cellcolorinfo, 'startfromzero', 'issplit' );
            oldfns = fieldnames( s.secondlayer.cellcolorinfo );
            newfns = fieldnames( gSecondLayerColorInfo );
            deletedfns = setdiff( oldfns, newfns );
            addedfns = setdiff( newfns, oldfns );
            s.secondlayer.cellcolorinfo = safermfield( s.secondlayer.cellcolorinfo, deletedfns );
            s.secondlayer.cellcolorinfo = defaultStructArrayFromStruct( s.secondlayer.cellcolorinfo, gSecondLayerColorInfo, addedfns );
        end
        if isfield( s.secondlayer, 'customcellcolorinfo' )
            oldfns = fieldnames( s.secondlayer.customcellcolorinfo );
            newfns = fieldnames( gSecondLayerColorInfo );
            deletedfns = setdiff( oldfns, newfns );
            addedfns = setdiff( newfns, oldfns );
            s.secondlayer.customcellcolorinfo = safermfield( s.secondlayer.cellcolorinfo, deletedfns );
            s.secondlayer.customcellcolorinfo = defaultFromStruct( s.secondlayer.cellcolorinfo, gSecondLayerColorInfo, addedfns );
        end
    end

    s.plotdefaults = upgradePlotoptions( s.plotdefaults );
end
