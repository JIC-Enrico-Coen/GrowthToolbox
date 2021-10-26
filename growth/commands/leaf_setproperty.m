function m = leaf_setproperty( m, varargin )
%m = leaf_setproperty( m, ... )
%   Set global properties of the leaf.
%   The arguments are a series of name/value pairs.
%
%   The property names that this applies to are:
%       'poisson'       Poisson's ratio.  The normal value is 0.35 and
%                       there is little need to change this.
%       'bulkmodulus'   The bulk modulus.  The normal value is 1 and
%                       there is little need to change this.
%       'validate'      Whether to validate the mesh after every iteration.
%                       This is for debugging purposes and should normally
%                       be off.
%       'displayedgrowth'    Specifies which morphogen to plot.
%
%       ...and many, many others.
%
%   Example:
%       m = leaf_setproperty( m, 'poisson', 0.49 );
%
%   Equivalent GUI operation: several GUI elements are implemented by this
%   command:
%       poisson:        Text box in "Mesh editor" panel.
%       bulkmodulus:    No GUI equivalent.
%       residstrain:    "Strain retention" in "Simulation" panel.
%       validate:       No GUI equivalent.
%       displayedgrowth:  "Displayed m'gen" menu in "Morphogens" panel.
%       ...etc.
%
%   If the mesh belongs to a GFtbox project, the project static file is
%   rewritten, unless one of the properties is 'staticreadonly' and its
%   value is true. In that case the static file will not be written.
%
%   Topics: Misc.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    if isempty(s), return; end

    dictionary = struct( ...
        'poisson', 'poissonsRatio', ...
        'do_validate', 'validateMesh', ...
        'do_growth', 'growthEnabled', ...
        'do_diffusion', 'diffusionEnabled', ...
        'do_interaction', 'allowInteraction', ...
        'do_splitlongfem', 'allowSplitLongFEM', ...
        'do_splitbentfem', 'allowSplitBentFEM', ...
        'do_splitbio', 'allowSplitBio', ...
        'do_flip', 'allowFlipEdges', ...
        'usetensors', 'useGrowthTensors', ...
        'plastic', 'plasticGrowth', ...
        'springy', 'springyGrowth' ...
    );

    s = safermfield( s, 'hybridMesh' ); % Cannot be altered by this procedure.

    staticchanged = false;
%     for i=1:2:(length(varargin)-1)
    fns = fieldnames(s);
    for fni=1:length(fns)
        fieldname = fns{fni};
        fieldvalue = s.(fieldname);
%         fieldname = varargin{i};
%         fieldvalue = varargin{i+1};
        if isfield( dictionary, fieldname )
            fieldname = dictionary.(fieldname);
        end
        if isfield( m.globalProps, fieldname )
            m.globalProps.(fieldname) = fieldvalue;
            staticchanged = true;
        elseif isfield( m.globalDynamicProps, fieldname )
            m.globalDynamicProps.(fieldname) = fieldvalue;
        elseif ischar( fieldname )
            fprintf( 1, '%s: unexpected property ''%s'' ignored.\n', mfilename(), fieldname );
        else
            fprintf( 1, '%s: property name expected, object of type "%s" found.\n', ...
                mfilename(), class( fieldname ) );
        end
    end
    
    if isfield(s,'poisson') || isfield(s,'poissonsRatio') || isfield(s,'bulkmodulus')
        m = updateElasticity( m );
    end
    
    if isfield(s,'colors') || isfield(s,'colorvariation')
        m.globalProps.colorparams = ...
            makesecondlayercolorparams( m.globalProps.colors, m.globalProps.colorvariation );
    end
    
    if isfield( s, 'biocolormode' ) && strcmp( s.biocolormode, 'area' )
        m = setSecondLayerColorsByArea( m );
    end
    
    if isfield( s, 'twosidedpolarisation' )
        m = setTwoSidedPolarisation( m, s.twosidedpolarisation );
    end
    
    if staticchanged
        saveStaticPart( m );
    end

    m.saved = 0;
end

