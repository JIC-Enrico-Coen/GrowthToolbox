function axisBounds = roundAxisBounds( varargin )
%axisBounds = roundAxisBounds( axisBounds )
%   Rounds the axisbounds away from zero so as to make them all a power of
%   10 multipled by 1, 2, or 5. For this way of calling roundAxisBounds,
%   axisBounds may have any shape.
%
%axisBounds = roundAxisBounds( ax, axisBounds )
%   Rounds the axisbounds as above, and applies them to the given axes.
%
%axisBounds = roundAxisBounds( ax )
%   Gets the current axis bounds, then performs as above.
%
%axisBounds = roundAxisBounds()
%   Applies the above to the current axes. If there are no current axes,
%   then [] is returned. New axes are not created.
%
%   SEE ALSO: ceil125

    switch nargin
        case 0
            fig = get(0, 'CurrentFigure');
            if ishghandle(fig)
                ax = fig.CurrentAxes;
                if isempty(ax)
                    axisBounds = [];
                else
                    axisBounds = axis(ax);
                end
            else
                ax = [];
            	axisBounds = [];
            end
        case 1
            if ishghandle( varargin{1} )
                ax = varargin{1};
                axisBounds = axis(ax);
            else
                ax = [];
                axisBounds = varargin{1};
            end
        otherwise
            ax = varargin{1};
            axisBounds = varargin{2};
    end
    axisBounds = ceil125( axisBounds );
    if ~isempty(ax)
        axis( ax, axisBounds );
    end
end

function x = floor125( x )
% Round x towards zero until it is a power of 10 multiplied by 1, 2, or 5.
%
%   SEE ALSO: ceil125, round125

    log10two = 0.30103;
    
    log10five = 0.55555;
    signx = sign(x);
    x = abs(x);
    lx = log10(x);
    y = floor(lx);
    z = lx-y;
    x = 10.^y;
    
    select2 = z < log10two;
    x(select2) = x(select2).*2;
    select5 = (~select2) & (z < log10five);
    x(select5) = x(select5).*5;
    x = x .* signx;
end

function x = ceil125( x )
% Round x away from zero until it is a power of 10 multiplied by 1, 2, or 5.
%
%   SEE ALSO: floor125, round125, roundAxisBounds

    log10two = 0.30103000;
    log10five = 0.69897000;
    
    signx = sign(x);
    x = abs(x);
    lx = log10(x);
    y = floor(lx);
    z = lx-y;
    x = 10.^y;
    select10 = z > log10five;
    
    x(select10) = x(select10).*10;
    select5 = (~select10) & (z > log10two);
    x(select5) = x(select5).*5;
    select2 = (~select10) & (~select5) & (z > 0);
    x(select2) = x(select2).*2;
    x = x .* signx;
end

function x = round125( x )
% Round x to the nearest number that is a power of 10 multiplied by 1, 2, or 5.
%
%   SEE ALSO: floor125, ceil125

    log10five = 0.69897000;
    log10sqrttwo = 0.15051500;
    log10sqrtten = 0.50000000;
    log10sqrtfifty = log10sqrtten + log10five/2;
    
    signx = sign(x);
    x = abs(x);
    lx = log10(x);
    y = floor(lx);
    z = lx-y;
    x = 10.^y;
    
    select2 = (z >= log10sqrttwo) & (z < log10sqrtten);
    select5 = (z >= log10sqrtten) & (z < log10sqrtfifty);
    select10 = (z >= log10sqrtfifty);
    x(select2) = x(select2).*2;
    x(select5) = x(select5).*5;
    x(select10) = x(select10).*10;
    x = x .* signx;
end
