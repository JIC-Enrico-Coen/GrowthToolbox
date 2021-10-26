function [m,ok] = leaf_saveas( m, varargin )
%m = leaf_save( m, filename, folderpath, ... )
%   Save the leaf to a file.
%   The way the leaf is saved depends on the extension of the filename:
%       .MAT    The leaf is saved in a MAT file as a Matlab object called
%               m.
%       .M      Matlab commands to recreate this leaf are saved in a .M
%               file.
%       .OBJ    Only the nodes and triangles are saved, in OBJ format.
%       .MSR    Whatever data will fit into MSR format are saved.
%       .WRL    The nodes and triangles, and either vertex or face colours
%               are saved, in VRML 97 format.
%       .DAE    The nodes and finite elements, and either vertex or face
%               colours are saved, in Collada DAE format.
%       .STL    The finite elements are subdivided into tetrahedrons and
%               saved in STL format.
%       .FIG    The current plot of the leaf is saved as a figure file.
%   All of these formats except FIG can be read back in by leaf_load.
%   Note that OBJ format discards all information except the geometry of
%   the mesh.
%
%   If the filename is just an extension (including the initial "."), then
%   a filename will be prompted for, and the specified extension will be
%   the default.  If no filename is given or the filename is empty, then
%   one will be prompted for, and any of the above extensions will be accepted.
%
%   The folder path specifies what folder to save the file in.  If not
%   specified, then the default folder will be chosen, which depends on the
%   file extension.  If a filename is then prompted for, the file dialog
%   will open at that folder, but the user can navigate to any other.
%   If the filename is a full path name then the folder name will be
%   ignored and the file will be stored at the exact location specified by
%   filename.
%
%   Options:
%       overwrite:  If true, and the output file exists already, it will
%           be overwritten without warning.  If false (the default), the
%           user will be asked whether to overwrite it.
%       minimal:  For OBJ files, if this is true (the default), then only
%           the vertexes and triangles of the mesh, and either vertex or
%           face colours will be written.  OBJ files of this
%           form should be readable by any program that claims to read OBJ
%           files.  If false, more of the information in the
%           mesh will be written, including all of the morphogen names and
%           values, in an ad-hoc extension of OBJ format.  (The prefix 'mn'
%           is used for morphogen names, and 'm' for values: each 'm' line
%           lists all the morphogen values for a single vertex.)
%       throughfaces: For OBJ files, if this is true, then for every edge
%           of the mesh, there will be a pair of triangles representing the
%           quadrilateral connecting the two copies that edge on the two
%           sides of the mesh.  If false (the default), this will only be
%           done for edges on the rim of the canvas.
%       bbox: If supplied and nonempty, this is either a bounding box (a
%             6-tuple [xmin xmax ymin ymax zmin zmax]) or a size (a triple
%             [xsize ysize zsize]), or a single number size.  A single
%             number size is equivalent to [size size size], and a triple
%             [xsize ysize zsize] is equivalent to a bounding box [-xsize/2
%             xsize/2 -ysize/2 ysize/2 -zsize/2 zsize/2].  For OBJ and VRML
%             format only, the model will be translated and uniformly
%             scaled so as to best fit into the box.
%       cells: For OBJ files, write the cells as well as the mesh.
%
%   Equivalent GUI operations: the "Save model..." button (saves as MAT
%   file) or the "Save script...", "Save OBJ...", or "Save FIG..." menu
%   commands on the "Mesh" menu.
%
%   Topics: Project management.

    if isempty(m), return; end
    matext = 'mat';
    mfileext = 'm';
    objext = 'obj';
    msrext = 'msr';
    stlext = 'stl';
    figext = 'fig';
    vrmlext = 'wrl';
    daeext = 'dae';
    extensions = { matext, mfileext, objext, msrext, stlext, figext, vrmlext, daeext };

    askForFile = 0;
    if isempty(varargin) || isempty(varargin{1})
        askForFile = 1;
        filterspec = outputFilterspec( extensions );
    else
        for i=1:length(extensions)
            if strcmpi( varargin{1}, ['.' extensions{i}] )
                askForFile = 1;
                filterspec = outputFilterspec( extensions(i) );
                break;
            end
        end
    end
    if length(varargin) >= 2
        dirname = varargin{2};
    else
        dirname = '';
    end
    s = struct();
    if length(varargin) >= 3
        [s,ok] = safemakestruct( mfilename(), varargin(3:end) );
        if ~ok, return; end
    end
    s = defaultfields( s, ...
        'overwrite', 0, ...
        'minimal', true, ...
        'throughfaces', true, ...
        'mesh', true, ...
        'cells', true, ...
        'cellcolor', m.secondlayer.cellcolor, ...
        'bbox', [], ...
        'image', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'overwrite', 'minimal', 'throughfaces', 'mesh', 'cells', 'cellcolor', 'bbox', 'image' );
    if ~ok, return; end
    queryOverwrite = ~s.overwrite;
    
    if ~isempty(s.bbox)
        if length(s.bbox)==1
            s.bbox = [-s.bbox s.bbox -s.bbox s.bbox -s.bbox s.bbox]/2;
        elseif length(s.bbox)==3
            s.bbox = [-s.bbox(1) s.bbox(1) -s.bbox(2) s.bbox(2) -s.bbox(3) s.bbox(3)]/2;
        elseif length(s.bbox) ~= 6
            fprintf( 1, '%s: Invalid bbox argument has %d elements: 0, 1, 3, or 6 required. Ignored\n', ...
                mfilename(), length(s.bbox) );
            s.bbox = [];
        end
    end
    
    if ~isempty( dirname )
        targetdir = dirname;
    elseif ~isempty(m.globalProps.modelname)
        targetdir = fullfile( m.globalProps.projectdir, ...
                              m.globalProps.modelname );
    else
        targetdir = '';
    end
    if isempty( targetdir )
        olddir = goToProjectDir( m, 'meshes' );
    else
        try
            olddir = cd( targetdir );
        catch
            fprintf( 1, ...
                '%s: Cannot find folder %s.  Using directory %s.\n', ...
                mfilename(), targetdir, pwd() );
            olddir = '';
        end
    end
    
    if askForFile
        [filename,filepath,filterindex] = uiputfile( ...
            filterspec, 'Save the leaf' );
        tryuncd( olddir );
        if filterindex==0, return; end
        if filename==0, return; end
        fileext = filterspec{filterindex,1};
        fileext = fileext(2:end);  % Get rid of the '*'.
        [~,xfilename,xfileext] = fileparts( filename );
        filename = xfilename;
        if queryOverwrite && ~isempty(xfileext)
            fileext = xfileext;
            goAhead = confirmOverwrite( fullfile( filepath, [ filename , fileext ] ) );
            if ~goAhead, return; end
        end
    else
        filename = varargin{1};
        if ~ischar(filename)
            fprintf( 1, ...
                '%s requires a file name as the second argument. Mesh not saved.\n', ...
                mfilename() );
            return;
        end
        if exist( filename, 'dir' )
            fprintf( 1, '%s: there is already a folder called %s. Mesh not saved.\n', ...
                mfilename(), filename );
            return;
        end
        if queryOverwrite && ~confirmOverwrite( filename )
            return;
        end
        [filepath,filename,fileext] = fileparts( filename );
    end
    
    switch fileext
        case ['.' msrext]
            writemeshmsr( filepath, [ filename, fileext ], m );
        case ['.' objext]
            writemeshobj( filepath, [ filename, fileext ], m, ...
                'surface', ~m.plotdefaults.thick, ...
                'minimal', s.minimal, ...
                'throughfaces', s.throughfaces, ...
                'mesh', true, ...
                'cells', s.cells, ...
                'bbox', s.bbox );
        case ['.' stlext]
            writemeshstl( filepath, [ filename, fileext ], m );
        case ['.' matext]
            % Finite element definitions are class objects and cannot be saved in
            % .mat files, because the class definition might change.
            % Replace each one by its specification.
            temp = m.FEsets;
            for i=1:length(m.FEsets)
                m.FEsets(i).fe = GetSpecification( m.FEsets(i).fe );
            end
%             save( fullfile( filepath, filename ), '-struct', 'm' );
            [~] = save_7_or_73( fullfile( filepath, filename ), m, true );
            m.FEsets = temp;
        case ['.' figext]
            if haspicture( m )
                saveas( m.pictures(1), ...
                        fullfile( filepath, filename ), 'fig' );
            else
                saveas( gcf(), ...
                        fullfile( filepath, filename ), 'fig' );
            end
        case ['.' vrmlext]
            theaxes = getGFtboxAxes( m );
            if isempty( theaxes )
                cp = [];
            else
                cp = getCameraParams( theaxes );
            end
            if isVolumetricMesh( m )
                g = meshTo3DModel( m );
                writegeomvrml( g, fullfile( filepath, [ filename, fileext ] ), cp, false );
            else
                writemeshvrml( filepath, [ filename, fileext ], m, s.bbox, cp );
            end
        case ['.' daeext]
            if isVolumetricMesh( m )
                g = meshTo3DModel( m );
                geom2dae( fullfile( filepath, [ filename, fileext ] ), g );
            else
                fprintf( 1, 'DAE format not supported yet for laminar meshes: "%s%s".  Mesh not saved.\n', ...
                    filename, fileext );
            end
        otherwise
            fprintf( 1, 'Unknown file format requested: "%s%s".  Mesh not saved.\n', ...
                filename, fileext );
    end
end

