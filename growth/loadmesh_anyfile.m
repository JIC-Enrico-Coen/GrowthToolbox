function [m,ok] = loadmesh_anyfile( m, filename, staticdata, interactive, checkValidity )
%m = loadmesh_anyfile( m, filename, staticdata, interactive )
%   Load a mesh from a file.
%   The expected format depends on the extension of the filename:
%       .OBJ    Contains only nodes and triangles, in OBJ format.  All
%               other properties of the mesh will be set to their default
%               values.
%       .MAT    The mesh is contained in the file either as a GFtbox mesh
%               structure called m, or as all the separate fields of such a
%               structure.  If staticdata is a struct, its fields overwrite
%               data loaded from filename.  If staticdata is a string, it
%               will be assumed to be a MAT-file containing the static
%               data.  If staticdata is the boolean value true, then a
%               static file will be looked for in the same directory as the
%               MAT-file and loaded.  staticdata is ignored for file
%               formats other than .MAT.
%       .M      The file contains Matlab commands to create or modify a
%               mesh.  These commands will be executed.
%   All of these formats can be generated by leaf_save.
%   In the case of .OBJ and .MAT files, the existing mesh will be
%   discarded.  A .M file will discard the current mesh only if it contains
%   a command to create a new mesh.

    global gPlotHandles gUNSAVEDFIELDS gDEFAULTFIELDS
    
    setGlobals();

    if nargin < 3
        staticdata = [];
    end
    if (nargin < 4) || isempty( interactive )
        interactive = false;
    end
    if (nargin < 5) || isempty( checkValidity )
        checkValidity = true;
    end
    objext = '.obj';
    matext = '.mat';
    mfileext = '.m';
    
    ok = true;
    
%     [realprojectdir,relfilename] = findAncestorGFtboxProject( filename );
    [modeldir,modelname,modelext] = fileparts( filename );
    [projectdir,modeldirname] = dirparts( modeldir );
    if ~strcmp( modeldirname, modelname )
    %   warning( ['GFtbox:' mfilename()], ...
    %       '%s: model directory %s and model file %s%s have different names.\n', ...
    %       mfilename(), modeldirname, modelname, modelext );
    end
    modelnamewithext = [modelname,modelext];
    fullname = fullfile( modeldir, modelnamewithext );

    if isempty(modeldir)
        filesource = modelnamewithext;
    else
        filesource = [ modelnamewithext ' in ' modeldir ];
    end
    
    switch modelext
        case objext
            fprintf( 1, '%s: Loading OBJ file %s.\n', ...
                mfilename(), filesource );
            m = readMeshFromOBJ( modeldir, modelnamewithext );
            if isempty(m)
                ok = false;
            else
%                 m.globalProps.projectdir = projectdir;
%                 m.globalProps.modelname = modeldirname;
%                 m = upgrademesh( m, checkValidity );
            end
        case matext
            fprintf( 1, '%s: Loading MAT file %s.\n', ...
                mfilename(), filesource );
            if ~exist( fullname, 'file' )
                GFtboxAlert( interactive, '%s: No file %s.', mfilename(), fullname )
                ok = false;
                return;
            else
                try
                    z = load( fullname );
                catch e %#ok<NASGU>
                    GFtboxAlert( interactive, '%s: Cannot load %s.', mfilename(), fullname )
                    e
                    ok = false;
                    return;
                end
            end
            % A mesh file can contain either a single variable called 'm',
            % whose value is a GFtbox mesh, or all the fields of a GFtbox
            % mesh stored as separate variables.  The latter format is
            % preferable, but the former is supported for legacy reasons.
            if isGFtboxMesh( z )
                m = z;
            elseif isfield(z,'m') && ~isempty(z.m)
                m = z.m;
            else
                GFtboxAlert( interactive, ...
                    '%s: Project invalid: MAT file %s does not contain a GFtbox mesh.', ...
                    mfilename(), filesource );
                ok = false;
                return;
            end
            clear z;
            
            for i=1:length(gUNSAVEDFIELDS)
                fn = gUNSAVEDFIELDS{i};
                m.(fn) = gDEFAULTFIELDS.(fn);
            end
            
            m.globalProps.projectdir = projectdir;
            m = makeModelNamesConsistent( m, fullfile( projectdir, modeldirname ) );
            m = upgrademesh( m, checkValidity );
            m.plotdata = struct([]);
            [m,ok] = loadStaticData( m, staticdata );

            % Some data are not valid when loaded from a file and must be
            % reconstituted or deleted.
            
            % The raw plot data is likely to be obsolete when a mesh is
            % loaded.
            m.plotdefaults = deleteRawPlotData( m.plotdefaults );
            % The projectdir and modelname are defined by where we loaded
            % the file from.
            m.globalProps.projectdir = projectdir;
            m.globalProps.modelname = modeldirname;
            m.globalProps.allowsave = 1;
            % Movie and handle data are necessarily invalid for a newly
            % loaded mesh.
            m.globalProps.mov = [];
            m.globalProps.allowsave = 1;
            m.plothandles = gPlotHandles;
            % Finite element types must be recreated from their
            % specifications.
            for i=1:length(m.FEsets)
                m.FEsets(i).fe = FiniteElementType.MakeFEType( m.FEsets(i).fe );
            end
        case mfileext
            fprintf( 1, '%s: Executing commands from %s.\n', ...
                mfilename(), filesource );
            if ~isempty(modeldir)
                prevdir = cd(modeldir);
            end
            m = docommands( m, modelnamewithext, 'nostop' );
            if ~isempty(modeldir)
                cd(prevdir);
            end
        otherwise
            ok = false;
            GFtboxAlert( interactive, '%s: Unknown file format: %s.  Mesh not loaded.\n', ...
                mfilename(), filename );
    end
end

function po = deleteRawPlotData( po )
    rawdatafields = { 'pervertex', ...
        'perelement', ...
        'tensor', ...
        ... % 'morphogen', ...
        ... % 'outputquantity', ...
        ... % 'defaultmultiplottissue', ...
        ... % 'blank', ...
        ... % 'axesquantity', ...
        ... % 'axesdrawn', ...
        ... % 'outputaxes', ...
        'perelementaxes', ...
        'perelementcomponents' };
    for i=1:length(rawdatafields)
        fn = rawdatafields{i};
        po.(fn) = [];
        po.([fn 'A']) = [];
        po.([fn 'B']) = [];
    end
end

