function h = lineMulticolor( varargin )
%lineMulticolor( varargin )
%   This is a version of the Matlab function line() which allows a
%   colour per segment to be specified. This does not necessarily emulate
%   the behaviour of line() in every detail, but most forms of calls to
%   line() should work.
%
%   The 'Color' option can be an N*3 array, specifying one color for each
%   column of the X, Y, and Z values. Indexed color is also supported. If
%   there is an option 'ColorIndex', then this must be an array of indexes
%   of rows of Color, as many indexes as there are lines. The 'Color'
%   option then need contain each colour just once.

    handlearg = 0;
    numnumericargs = 0;
    
    curarg = 1;
    while true
        if curarg > nargin
            break;
        end
        if (curarg==1) && ~isnumeric(varargin{curarg}) && ishghandle(varargin{curarg})
            handlearg = 1;
        elseif isnumeric(varargin{curarg})
            numnumericargs = numnumericargs+1;
        else
            break;
        end
        curarg = curarg+1;
    end
    
    numspecialargs = handlearg + numnumericargs;
    
    coloroption = [];
    colorindexoption = [];
    for i = (numspecialargs+1):2:nargin
        if strcmpi( varargin{i}, 'Color' )
            if size(varargin{i+1},1) > 1
                coloroption = i;
            end
        elseif strcmpi( varargin{i}, 'ColorIndex' )
            if size(varargin{i+1},1) > 1
                colorindexoption = i;
            end
        end
    end
    
    if isempty(coloroption) && isempty( colorindexoption )
        numlines = size( varargin{handlearg+1}, 2 );
        for i=1:numnumericargs
            varargin{handlearg+i} = reshape( [ varargin{handlearg+i}; NaN(1,numlines) ], [], 1 );
        end
        h = line( varargin{:} );
        return;
    end
    
    % If we reach here, then there is a Color option specifying more than
    % one color.
    
    if ~isempty(colorindexoption)
        colorindexes = varargin{colorindexoption+1};
        varargin([colorindexoption colorindexoption+1]) = [];
    end
    s = struct( varargin{(numspecialargs+1):end} );
    if handlearg==1
        s.Parent = varargin{1};
    end
    if numnumericargs >= 1
        s.XData = varargin{handlearg+1};
    end
    if numnumericargs >= 2
        s.YData = varargin{handlearg+2};
    end
    haveZ = false;
    if numnumericargs >= 3
        haveZ = true;
        s.ZData = varargin{handlearg+3};
    end
    
    [ucolor,~,ic] = unique( s.Color, 'rows' );
    if isempty( colorindexoption )
        colorindexes = ic;
    else
        colorindexes = ic( colorindexes );
    end
    numlines = size( ucolor, 1 );
    h(numlines) = matlab.graphics.GraphicsPlaceholder;
    
    s1 = s;
    emptygh = false( 1, numlines );
    for i=1:numlines
        % Find all columns for this color.
        selectedcols = colorindexes==i;
        nans = nan( 1, sum(selectedcols) );
        if isempty(nans)
            emptygh(i) = true;
            continue;
        end
        s1.XData = reshape( [s.XData(:,selectedcols); nans], [], 1 );
        s1.YData = reshape( [s.YData(:,selectedcols); nans], [], 1 );
        if haveZ
            s1.ZData = reshape( [s.ZData(:,selectedcols); nans], [], 1 );
        end
        s1.Color = ucolor(i,:);
        args = reshape( [ fieldnames(s1),  struct2cell(s1) ]', 1, [] );
        h(i) = line( args{:} );
    end
    h(emptygh) = [];
end
