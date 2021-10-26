function m = leaf_set_cellfactor( m, varargin )
%m = leaf_set_cellfactor( m, varargin )
%   Set the value of a cellular factor.
%
%   Options:
%
%   'factor'    The name or index of the factor to operate on.
%   'operation' One of 'zero', 'const', 'random', 'radial', 'linear', or
%               'value', specifying a method of setting the value.  These
%               mean:
%                   'zero'  Set the factor everywhere to zero.
%                   'const'  Set the factor everywhere to the value
%                       specified by the 'amount' option.  In this case,
%                       the 'amount' option can be either a single value or
%                       a value per cell.
%                   'random'  Set the factor everywhere to a random value
%                       uniformly distributed between 0 and the 'amount'.
%                   'linear'  Set the factor to a linear gradient according
%                       to location in the XY plane in the direction given
%                       by the 'direction' option, and ranging from 0 to
%                       'amount'.
%   'allowedvalues'    Relevant for all operations except 'zero'.  If empty
%               (the default) it has no effect.  Otherwise, it is a list of
%               the allowed values for the factor.  The values computed
%               form the other options are replaced by the closest value in
%               this list.  If this option is 'bool', that is equivalent to
%               [0 1].
%   'amount'    Relevant for all operations except 'zero'.  Either a single
%               number specifying the maximum amount to apply, or two
%               numbers specifying the minimum and maximum amounts (in
%               either order). When the operation is 'const', 'amount' is
%               either a single number or a value per cell.
%   'centre'    Relevant to the 'radial' operation.  Specifies the point
%               from which the radius is to be measured. Default [0 0 0].
%   'direction' Relevant to the 'linear operation.  Specifies a direction
%               in the XY plane, measured anticlockwise from the X axis in
%               radians.  Default 0.
%   'add'       A boolean.  If true the amount will be
%               added to the current value.  If false, the amount will
%               replace the current value.  The defualt is true except for
%               the 'zero' operation, when the default is false.
%
%   Invalid or unnecessary arguments are ignored.
%
%   Topics: Cellular factors.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'factor', [], 'operation', 0, 'amount', 0, 'allowedvalues', [], 'centre', [0 0 0], 'direction', 0, 'add', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'factor', 'operation', 'amount', 'allowedvalues', 'centre', 'direction', 'add' );
    if ~ok, return; end
    if isempty( s.factor )
        return;
    end
    if ~ischar( s.factor ) && (numel(s.factor) > 1)
        fprintf( 1, '%s: Can only operate on a single cell factor, %d supplied.\n', numel(s.factor) );
        return;
    end
    if isempty(s.add)
        if strcmp( s.operation, 'zero' )
            s.add = false;
        else
            s.add = true;
        end
    end
    if strcmp( s.allowedvalues, 'bool' )
        s.allowedvalues = [0 1];
    end
    if ~strcmp( s.operation', 'const' )
        if numel(s.amount)==2
            minamount = s.amount(1);
            maxamount = s.amount(2);
        else
            minamount = 0;
            maxamount = s.amount(1);
        end
    end
    
    selmgen = name2Index( m.secondlayer.valuedict, s.factor );
    if selmgen==0
        return;
    end
    scaling = false;
    

    switch s.operation
        case 'zero'
            values = zeros(getNumberOfCells(m),1);
            s.add = false;
        case 'invert'
            values = ...
                ... % min( m.secondlayer.cellvalues(:,selmgen) ) ...
                ... % + max( m.secondlayer.cellvalues(:,selmgen) ) ...
                - m.secondlayer.cellvalues(:,selmgen);
            s.add = false;
        case 'const'
            values = s.amount;
        case 'random'
            values = rand(size(m.secondlayer.cellvalues,1),1);
            scaling = true;
        case 'radial'
            cc = biocellcentres( m );
            rsq = sum( (cc - repmat( s.centre, size(cc,1), 1 )).^2, 2 );
            maxrsq = max(rsq);
            if maxamount < 0
                rsq = maxrsq-rsq;
            end
            values = rsq/maxrsq;
            scaling = true;
        case 'linear'
            cc = biocellcentres( m );
            dotprods = cos(s.direction).*cc(:,1) + sin(s.direction).*cc(:,2);
            dotprods = dotprods - min(dotprods);
            values = dotprods/max(dotprods);
            scaling = true;
        otherwise
            % Ignore.
    end
    if scaling
        values = values * (maxamount-minamount) + minamount;
    end
    if s.add
        values = values + m.secondlayer.cellvalues(:,selmgen);
    end
    if ~isempty( s.allowedvalues )
        values = discretiseValues( s.allowedvalues, values );
    end
    m.secondlayer.cellvalues(:,selmgen) = values;
end
