function m = leaf_loadgrowth( m, varargin )
%m = leaf_loadgrowth( m, filename )
%   Load growth data for the leaf from an OBJ or MAT file.  If no filename
%   is given, one will be asked for.
%
%   This assumes the mesh is in growth/anisotropy mode.
%
%   Equivalent GUI operation: the "Load Growth..." button on the
%   "Morphogens" panel.
%
%   Topics: Files, Mesh editing.

    if isempty(m), return; end
    setGlobals();

    objext = '.obj';
    matext = '.mat';

    filename = '';
    s.project = '';
    olddir = '';
    if ~isempty(varargin)
        if ~strcmp( varargin{1}, 'project' )
            [ok, filename, args] = getTypedArg( mfilename(), 'char', varargin );
            if ~ok, return; end
            [s,ok] = safemakestruct( mfilename(), args );
        else
            [s,ok] = safemakestruct( mfilename(), varargin );
        end
        if ~ok, return; end
        ok = checkcommandargs( mfilename(), s, 'exact', 'project' );
        if ~ok, return; end
    end

    if ~isempty( s.project )
        meshdir = fullfile( s.project, 'meshes' );
        try
            olddir = cd( meshdir );
        catch
            fprintf( 1, '%s: project directory %s does not exist. Mesh not loaded.\n', mfilename(), meshdir );
            return;
        end
    elseif (~isempty(m)) ...
            && isfield(m,'globalProps') ...
            && isfield(m.globalProps,'projectdir') ...
            && (~isempty(m.globalProps.projectdir))
        olddir = goToProjectDir( m, 'meshes' );
        if isempty(olddir), return; end
    end

    if isempty(filename)
        filters = ...
            { ['*' objext ';*' matext], 'All suitable'; ...
              ['*' objext],             'OBJ files'; ...
              ['*' matext],             'MAT files'; ...
              '*',                      'All files' ...
            };
        [filename,filepath] = uigetfile( ...
            filters, 'Load a growth map' );
        if filename==0
            if olddir, cd( olddir ); end
            return;
        end
        [xfilepath,xfilename,fileext] = fileparts( filename );
    else
        [filepath,filename,fileext] = fileparts( filename );
        filename = [filename,fileext];
    end

    fullname = fullfile( filepath, filename );

    if isempty(filepath)
        filesource = filename;
    else
        filesource = [ filename ' in ' filepath ];
    end

    fprintf( 1, 'Loading growth data from file %s.\n', filesource );
    
    switch fileext
        case matext
            x = load( fullname );
            m = addgazedata( m, x );
        case objext
            m1 = readMeshFromOBJ( filepath, filename );
            if length(m.celldata) == length(m1.celldata)
                m.celldata = m1.celldata;
                unitmgens = FindMorphogenRole( m, {'KAPAR','KAPER','KBPAR','KBPER'} );
                m.morphogens(:,unitmgens) = 1;
%                 m.globalProps.targetAbsArea = m1.globalDynamicProps.currentArea;
%                 m.globalProps.targetRelArea = ...
%                     m.globalProps.targetAbsArea/m.globalProps.initialArea;
            else
                fprintf( 1, 'Growth data for %d cells expected, %d found.\n', ...
                    length(m.celldata), length(m1.celldata) );
            end
        otherwise
            fprintf( 1, 'Unknown file format: %s.  Growth data not loaded.\n', ...
                filename );
    end
    
    if olddir, cd( olddir ); end
end

function m = addgazedata( m, x )
    if isempty(x)
        errordlg( [ 'No data found in ', filename ], 'Load growth' )
        return;
    end
    xmin = min( m.nodes(:,1) );
    xmax = max( m.nodes(:,1) );
    ymin = min( m.nodes(:,2) );
    ymax = max( m.nodes(:,2) );
    xscale = (size(x.D.z,2) - 1)/(xmax - xmin);
    xoffset = 1 - xmin*xscale;
    yscale = (size(x.D.z,1) - 1)/(ymax - ymin);
    yoffset = 1 - ymin*yscale;
    zmax = max(max(x.D.z));
    k_mgens = FindMorphogenRole( m, {'KAPAR','KAPER'} );
    if zmax <= 0
        m.morphogens(:,[k_mgens]) = 0;
    else
        zscale = 100/zmax;
        for i=1:size(m.morphogens,1)
            m.morphogens( i, [k_mgens] ) = ...
                zscale * x.D.z( round( m.nodes(i,2)*yscale + yoffset ), ...
                                round( m.nodes(i,1)*xscale + xoffset ) );
        end
    end
    m = copyAtoB( m );
end
