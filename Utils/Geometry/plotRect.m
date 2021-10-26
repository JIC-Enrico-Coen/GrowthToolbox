function plotRect( r, varargin )
%plotRect( r )
%   Plot the rectangles r, an array of which each row has the form
%   [ xlo, xhi, ylo, yhi ].

    for i=1:size(r,1)
        patch( r(i,[1,1,2,2]), r(i,[3,4,4,3]), varargin{:} );
    end
end
