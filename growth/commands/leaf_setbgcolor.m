function m = leaf_setbgcolor( m, varargin )
%m = leaf_setbgcolor( m, color )
%
%   Set the background colour of the picture, and of any snapshots or
%   movies taken.  COLOR is a triple of RGB values in the range 0..1.
%
%   Topics: Plotting.

    if isempty(m), return; end
    if length( varargin ) ~= 1
        fprintf( 1, '%s: One argument required, %d supplied.\n', ...
            mfilename(), length( varargin ) );
        return;
    end
    color = varargin{1};
    if ~isnumeric(color)
        fprintf( 1, '%s: Numeric vector expected. Command ignored.\n', ...
            mfilename(), length( varargin ) );
        return;
    end
    if length(color)==1
        color = [ color, color, color ];
    else
        color = reshape(color, 1, []);
        if length(color) ~= 3
            fprintf( 1, '%s: Vector of 3 elements expected, %d found. Command ignored.\n', ...
                mfilename(), length( color ) );
            return;
        end
    end
    color = min(color,1);
    color = max(color,0);
        
    m = setPictureColor( m, color );
end

