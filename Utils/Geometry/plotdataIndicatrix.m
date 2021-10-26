function [ellipsedata,axisdata] = plotdataIndicatrix( varargin )
%[ellipsedata,axisdata] = plotdataIndicatrix( positions, tensors, options... )
%[ellipsedata,axisdata] = plotdataIndicatrix( positions, pvalues, tensoraxes, options... )
%
%   The first two or three arguments specify the pocations at which
%   indicatrices for the corresponding tensors are to be drawn, and returns
%   data suitable for passing to plotIndicatrix, together with plotting
%   options and an axes object, to draw them.
%
%   POSITIONS is an N*3 matrix of N points.
%   TENSORS is either an N*6 or 3*3*N array specifying a set of N
%       symmetric tensors.  It will immediately be converted to PVALUES and
%       TENSORAXES.
%   PVALUES is an N*3 matrix giving the 3 principal values for each of the
%       N tensors.
%   TENSORAXES is a 3*3*N array giving the principal axes of each if the N
%       tensors, as the rows of the 3*3 matrices.
%
%   The remaining arguments specify options as name-value pairs.  The
%   options are:
%
%   'parts'     A subset of the string 'XYZxyz'  The letters X, Y, and Z
%       ask for ellipses to be drawn in the planes perpendicular to the
%       first, second, and third principal component respectively.  x, y,
%       and z ask for axis lines to be drawn parallel to those axes.  The
%       default is to draw all ellipses and axes.
%
%   'resolution'    The number of points per ellipse, default 12.
%
%   'scale' The amount by which to scale all the ellipses and axes, after
%       processing the 'scalemode' options.  Default 1.
%
%   'scalemode'  A string, default 'absolute'.  Possible values are:
%       'single'    For each tensor, scale its principal values so that the
%           largest is 1.
%       'global'    Scale its principal values of all the tensors together
%           so that the largest is 1. 
%       'absolute'  Do not do either of those scalings.
%
%   ELLIPSEDATA is a RESOLUTION*NUMELLIPSES*3 array, where RESOLUTION is
%   the valus of the 'resolution' option, and NUMELLIPSES is the number of
%   ellipses to be drawn (the number of tensors times how many of 'X', 'Y',
%   and 'Z' occur in the 'parts' option).  Its three slices along its third
%   dimension are suitable arguments to patch().
%
%   AXISDATA is a (NUMAXES*3)*3 array, where NUMAXES is the number of axis
%   lines to be drawn (the number of tensors times how many of 'x', 'y',
%   and 'z' occur in the 'parts' option).  Each set of three consecutive
%   rows are the two ends of an axis and a row of NaNs.  The three slices
%   of AXISDATA on its second dimension are suitable for passing to plot3
%   or line.

    ellipsedata = [];
    axisdata = [];
    if nargin < 2
        return;
    end
    dims = 3;
    positions = varargin{1};
    if (nargin==2) || ischar(varargin{3})
        [pvalues,tensoraxes] = tensorsToComponents( varargin{2} );
        options = struct( varargin{3:end} );
    else
        pvalues = varargin{2};
        tensoraxes = varargin{3};
        options = struct( varargin{4:end} );
    end
    options = defaultfields( options, ...
        'parts', 'XYZxyz', ...
        'resolution', 12, ...
        'scale', 1, ...
        'scalemode', 'absolute' );
    switch options.scalemode
        case 'single'
            % Scale each set of eigenvectors so that its largest is 1.
            maxvals = max( pvalues, [], 2 );
            pvalues = pvalues ./ repmat( maxvals, 1, dims );
        case 'global'
            % Scale the set of all eigenvectors so that the largest is 1.
            pvalues = pvalues ./ max( pvalues(:) );
        case 'absolute'
            % Nothing.
    end
    numtensors = size(pvalues,1);    
    pvalues = pvalues * options.scale;
    tensoraxes = tensoraxes .* repmat( permute( pvalues, [2 3 1] ), 1, dims, 1 );
    
    theta = linspace(0,2*pi,options.resolution+1)';
    c = cos(theta);
    s = sin(theta);
    npts = length(theta);
    elementmap = false(1,35);
    elementmap(options.parts-'W') = true;
    elementmap = elementmap( [1 2 3 33 34 35] );
    if ~any(elementmap)
        return;
    end
    ellipsesPerTensor = sum( elementmap(1:3) );
    
    if ellipsesPerTensor > 0
        cc = repmat( c, 1, dims, numtensors );
        ss = repmat( s, 1, dims, numtensors );
        pp = repmat( permute( positions, [3 2 1] ), npts, 1, 1 );
        ellipsedata = zeros( npts, dims, numtensors, ellipsesPerTensor );
        ai = 0;
        for i=1:3
            if elementmap(i)
                [j,k] = othersOf3(i);
                jaxes = repmat( tensoraxes(j,:,:), npts, 1, 1 );
                kaxes = repmat( tensoraxes(k,:,:), npts, 1, 1 );
                ai = ai+1;
                ellipsedata( :, :, :, ai ) = cc.*jaxes + ss.*kaxes + pp;
            end
        end
%         ellipsedata( end+1, :, :, : ) = NaN;
        ellipsedata = permute( reshape( ellipsedata, npts, dims, numtensors*ellipsesPerTensor ), [1 3 2] );
    else
        ellipsedata = [];
    end
    
    axesPerTensor = sum( elementmap(4:6) );
    if axesPerTensor > 0
        selectedaxes = elementmap(4:6);
        allpos = reshape( permute( repmat( positions, 1, 1, axesPerTensor ), [2 3 1] ), dims, [] )';
        allaxes = reshape( permute( tensoraxes( selectedaxes, :, : ), [2 1 3] ), dims, [] )';

        axisdata = reshape( [ allpos-allaxes, allpos+allaxes, nan(numtensors*axesPerTensor,3) ]', dims, [] )';
    else
        axisdata = [];
    end
end
