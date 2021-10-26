function [m,ok,moviefile] = leaf_movie( m, varargin )
%[m,ok,moviefile] = leaf_movie( m, ... )
%   Start or stop recording a movie.
%   Any movie currently being recorded will be closed.
%   If the first optional argument is 0, no new movie is started.
%   Otherwise, the arguments may contain the following option-value pairs:
%   FILENAME    The name of the movie file to be opened.  If this is not
%               given, and m.globalProps.autonamemovie is true, then a name
%               will be generated automatically, guaranteed to be different
%               from the name of any existing movie file. Otherwise, a file
%               selection dialog is opened.
%   AUTONAME    A boolean, by default equal to m.globalProps.autonamemovie.
%               If true, and no filename is given, the movie will have an
%               automatically generated name. Otherwise, a file
%               selection dialog is opened.
%   OVERWRITE   A boolean, by default equal to m.globalProps.overwritemovie.
%               If true, then if there is an existing movie of the same
%               name (whether the name was explicitly specified or
%               automatically generated) it will be overwritten.  If false,
%               then a numerical suffix will be added to the name (or will
%               replace such a suffix if present) to make a new movie file.
%   FINALSNAPSNOT  If true (the default), then when closing a movie a
%               snapshot will also be taken of the final state of the mesh.
%   FPS, COMPRESSION, QUALITY, KEYFRAME, COLORMAP, VIDEONAME: These options
%   are passed directly to the Matlab function AVIFILE.  LEAF_MOVIE provides
%   defaults for some of these:
%       FPS          15
%       COMPRESSION  'None'
%       QUALITY      100
%       KEYFRAME     5
%
%   OK is true if the operation was successful.
%
%   If a movie file was opened, MOVIEFILE is its full path name, otherwise
%   empty.
%
%   Equivalent GUI operation: clicking the "Record movie..." button.
%
%   See also AVIFILE.
%
%   Topics: Movies/Images.

    % A first argument of 0 means that any existing movie is closed and
    % no new movie is to be created.
    nonewmovie = ~isempty(varargin) && isnumeric(varargin{1}) && (varargin{1}==0);
    if nonewmovie
        varargin(1) = [];
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'autoname', m.globalProps.autonamemovie, 'overwrite', m.globalProps.overwritemovie );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'filename', 'moviedir', 'finalsnapshot', 'autoname', 'overwrite', ...
        'fps', 'compression', ...
        'quality', 'keyframe', 'colormap', 'videoname' );
    if ~ok, return; end
    
    autoname = s.autoname;
    overwrite = s.overwrite;
    s = rmfield( s, { 'autoname', 'overwrite' } );
    
    moviefile = '';
    if isempty(m), return; end
    if ~isempty(m.globalProps.mov)
        moviefilepath = m.globalProps.mov.Path;
        moviefilename = m.globalProps.mov.Filename;
        fprintf( 1, 'Closing movie file %s.\n', fullfile( moviefilepath, moviefilename ) );
        try
            close(m.globalProps.mov);
        catch e
            ok = false;
            GFtboxAlert( 1, 'Could not close movie:\n%s', e.message );
        end
        m.globalProps.mov = [];
        m.globalProps = safermfield( m.globalProps, 'movieframe' );
        if hasPicture( m )
            olddir = trycd( moviefilepath );
            [~,basename] = fileparts( moviefilename );
            figureFilename = fullfile( moviefilepath, basename );
            if (~isfield( s, 'finalsnapshot' ) || s.finalsnapshot) && ...
               ~( isfield(m.globalProps,'RecordMeshes') ...
                  && isfield( m.globalProps.RecordMeshes, 'flag' ) ...
                  && m.globalProps.RecordMeshes.flag ...
                  && isfield( m.globalProps.RecordMeshes, 'saveframe' ) ...
                  && m.globalProps.RecordMeshes.saveframe )
                m.globalProps.RecordMeshes.saveframe=false;
%                 fprintf( 1, 'Saving final frame at time %f as figure file %s.fig.\n', ...
%                     m.globalDynamicProps.currenttime, figureFilename );
%                 try
%                     saveas( m.pictures(1), figureFilename, 'fig' );
%                 catch
%                     GFtboxAlert( 1, 'Could not save figure to %s.fig.', figureFilename );
%                 end
                finalPicFileName = [figureFilename,'.png'];
                fprintf( 1, 'Saving snapshot of final frame to %s.\n', ...
                    finalPicFileName );
                frame = getGFtboxImage(m,[],m.plotdefaults.drawcolorbar);
                try
                    imwrite( frame, finalPicFileName );
                catch e
                    GFtboxAlert( 1, 'Could not save snapshot to %s:\n\n%s', finalPicFileName, e.message );
                    xxxx = 1;
                end
            end
            if ~isempty(m.globalProps.modelname)
                interaction_filename = fullfile('..',[makeIFname(m.globalProps.modelname),'.m']);
                targetname = [basename,'.txt'];
                if exist(interaction_filename,'file')==2
                    try
                        copyfile(interaction_filename,targetname);
                        fprintf(1,'Copied %s to %s\n',interaction_filename,targetname);
                    catch
                        GFtboxAlert( 1, 'Could not copy interaction function to %s.', targetname );
                    end
                end
            end
            if olddir, cd( olddir ); end
        end
    end
    m.globalProps.framesize = [];
    
    if nonewmovie
        return;
    end
    
    s = defaultfields( s, ...
        'fps', 15, ...
        'compression', 'Motion JPEG AVI', ...
        'quality', 75, ...
        'keyframe', 5 );
    s.fps = double(s.fps);  % Because it generates a bad movie file if
                            % it's an integer type.
    useNewMethod = true;
    if ~(exist( 'VideoWriter.m', 'file' )==2)
        if isinteractive(m)
            queryDialog( 1, 'Unable to perform operation', ...
                'Matlab function VideoWriter is not available.  Movie not created.' );
        else
            complain( 'Matlab function VideoWriter is not available.  Movie not created.' );
        end
        ok = false;
        return;
    end
    
    % The file name may be supplied explicitly, or default to the project
    % name, or be asked for.
    % The directory may be supplied by the filename, explicitly as the
    % 'moviedir' argument, or default to the project movies directory.
    
    filename = '';
    fileext = '';
    filepath = '';
    asked = 0;
    if isfield( s, 'filename' )
        % Use s.filename
        [filepath,filename,fileext] = fileparts( s.filename );
    elseif autoname && ~isempty(m.globalProps.modelname)
        % Invent a name.
        [filepath,filename,fileext] = fileparts( m.globalProps.modelname );
        filename = [ filename, '-0000' ];
    else
        % Ask.
        filterspec = {'*', 'All files'};
        % Go to movies directory.
        if isempty(m.globalProps.modelname)
            moviefilepath = pwd;
            olddir = '';
        else
            moviefilepath = fullfile( fullfile( m.globalProps.projectdir, m.globalProps.modelname ), 'movies' );
            moviefilepath = moviePath( m );
            olddir = trymkdircd( moviefilepath );
        end
        [filename, filepath, filterindex] = uiputfile( {'*','All files'}, 'Create a movie file');
        % Return to previous directory.
        if olddir, trycd( olddir ); end
        if (filterindex==0) || ~ischar(filename)
            % User cancelled.
            ok = false;
            return;
        end
        fileext = filterspec{filterindex,1};
        fileext = fileext(2:end);  % Get rid of the '*'.
        asked = 1;
        [xfilepath,filename,xfileext] = fileparts( filename );
        if ~isempty( xfileext )
            fileext = xfileext;
        end
    end
    
%     if isempty(fileext)
%         fileext = '.avi';
%     end
    
    if ~asked
        if isrootpath( filepath )
            % This is the directory to use.
        elseif isfield( s, 'moviedir' )
            % Directory is s.moviedir.
            filepath = s.moviedir;
        else
            % Directory is project movies directory.
            modeldir = getModelDir( m );
            filepath = fullfile( modeldir, 'movies' );
        end
    end
    
    filename = fullfile(filepath,[filename,fileext]);
    if (~asked) && (~overwrite)
        filename = newfilename( filename );
    end
    [filepath,filename,fileext] = fileparts( filename );
    
    s = safermfield( s, 'filename', 'moviedir' );
    
    olddir = trymkdircd( filepath );
    
    basemoviename = [ filename, fileext ];

    try
        m.globalProps.mov = VideoWriter( basemoviename, s.compression );
        moviefilepath = m.globalProps.mov.Path;
        moviefilename = m.globalProps.mov.Filename;
        set( m.globalProps.mov, 'FrameRate', s.fps );
        haveQuality = true;
        try
            set( m.globalProps.mov, 'Quality', s.quality );
        catch
            haveQuality = false;
        end
        open( m.globalProps.mov );
        fprintf( 1, 'Starting movie file %s.\n', fullfile( moviefilepath, moviefilename ) );
        if haveQuality
            fprintf( 1, 'Using %s (%s) compressor, %d quality.  Frame rate %d fps.\n', ...
                s.compression, ...
                get( m.globalProps.mov, 'VideoFormat' ), ...
                get( m.globalProps.mov, 'Quality' ), ...
                get( m.globalProps.mov, 'FrameRate' ) );
        else
            fprintf( 1, 'Using %s (%s) compressor.  Frame rate %d fps.\n', ...
                s.compression, ...
                get( m.globalProps.mov, 'VideoFormat' ), ...
                get( m.globalProps.mov, 'FrameRate' ) );
        end
        m.globalDynamicProps.framesinmovie = 0;
        m = recordframe( m );
    catch e
        % e = lasterror();
        GFtboxAlert( 1, 'Could not start movie:\n%s', ...
            regexprep( e.message, '<[^>]*>', '' ) );
        dbstack();
        m.globalProps.mov = [];
    end

    if olddir, cd( olddir ); end
end

        
