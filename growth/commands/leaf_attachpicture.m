function m = leaf_attachpicture( varargin )
%m = leaf_attachpicture( varargin )
%   NOT SUPPORTED.  INCOMPLETE.  NON-OPERATIONAL.
%   Load a picture from a file.  Create a rectangular mesh of the same
%   proportions.
%   If no filename is given for the picture, a dialog will be opened to
%   choose one.
%
%   Equivalent GUI operation: none.
%
%   Topics: HIDE, Picture distortion.

    bmpext = '.bmp';
    pngext = '.png';
    
    m = [];
    
    if isempty(varargin)
        [filename,filepath] = uigetfile( ...
            { ['*' bmpext ';*' pngext], 'All suitable'; ...
              ['*' bmpext],             'BMP files'; ...
              ['*' pngext],             'PNG files'; ...
              '*',                      'All files' ...
            }, ...
            'Load a picture file' );
        if filename==0
            return;
        end
    else
        filename = varargin{1};
        filepath = '';
        if ~ischar(filename)
            fprintf( 1, ...
                '%s requires a file name as the second argument. Leaf not saved.\n', ...
                mfilename() );
            return;
        end
    end
    [path,name,ext] = fileparts( filename );
    cd(path);
    if isempty(filepath)
        filesource = filename;
    else
        filesource = [ filename ' in ' filepath ];
    end
    fprintf( 1, 'Loading picture file %s.\n', filesource );
    try
        picture = imread( fullfile( filepath, filename ) );
    catch
        e = lasterror;
        beep;
        fprintf( 1, '** Warning: %s\nPicture not loaded, mesh not created.\n', e.message );
        return;
    end
    tag_size = floor( min( [ 50, 0.1 * size( picture, [1 2] ) ] ) );
    picture( 1:tag_size, 1:tag_size*2, 1 ) = 1;    % To show which axis is which
    picture( 1:tag_size, 1:tag_size*2, 2:3 ) = 0;  % and what direction it runs.
    
    growthfilename = [ name, '.gaz' ];
end
